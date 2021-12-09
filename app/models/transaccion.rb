class Transaccion < ActiveRecord::Base
  self.table_name = 'entradas_salidas'

  belongs_to :subarticle

  attr_accessor :cantidad_entrada
  attr_accessor :cantidad_salida
  attr_accessor :cantidad_saldo
  attr_accessor :importe_entrada_resumen
  attr_accessor :importe_salida_resumen
  attr_accessor :importe_saldo_resumen
  attr_accessor :items

  after_initialize :inicializar

  def self.entradas
    where(tipo: 'entrada')
  end

  # Despliega el saldo total de la lista
  # No funciona cuando hay un objeto adicionado dinámicamente
  def self.saldo
    all.sum(:cantidad)
  end

  def self.saldo_final(fecha = Date.today)
    saldo_final = Transaccion.new(
      fecha: fecha,
      cantidad: 0,
      detalle: 'SALDO FINAL'
    )
    saldo_final.crear_items(all.saldo_al(fecha))
    saldo_final
  end

  def self.saldo_final_resumen(fecha = Date.today)
    saldo_final = Transaccion.new(
      fecha: fecha,
      cantidad: 0,
      detalle: 'SALDO FINAL'
    )
    saldo_final.crear_items(all.saldo_al(fecha))
    saldo = saldo_final.items.sum(&:cantidad_saldo)
    importe_saldo = saldo_final.items.sum(&:importe_saldo)
    transaccion = {
      cantidad_saldo: saldo,
      importe_saldo_resumen: importe_saldo
    }
    saldo_final.items = [Transaccion.new(transaccion)]
    saldo_final
  end

  def self.saldo_inicial(fecha = Date.today)
    saldo_inicial = Transaccion.new(
      fecha: fecha,
      cantidad: 0,
      detalle: 'SALDO INICIAL'
    )
    saldo_inicial.crear_items(all.saldo_al(fecha))
    saldo_inicial
  end

  def self.salidas
    where(tipo: 'salida')
  end

  # Permite obtener el saldo a una determinada fecha en un objeto transaccion
  def self.saldo_al(fecha = Date.today)
    transacciones = all.where('fecha <= ?', fecha)
    unless transacciones.count.zero?
      saldo = transacciones.sum(:cantidad) # total que hay
      entradas = []
      transacciones.entradas.reverse.each do |entrada|
        entradas.prepend(entrada)
        entrada.fecha = fecha
        #entrada.detalle = ''
        entrada.cantidad_saldo = entrada.cantidad
        entrada.cantidad = 0 # Para saldos iniciales
        if (saldo - entrada.cantidad_saldo) > 0
          saldo -= entrada.cantidad_saldo
        else
          entrada.cantidad_saldo = saldo
          break
        end
      end
      return entradas
    end
    return []
  end

  # Utilizado en las vistas del valorado
  def self.suma_entradas(items, desde, hasta)
    item = items.last
    suma = +Transaccion.where(fecha: (desde..hasta),
                      subarticle_id: item.subarticle_id,
                      tipo: 'entrada')
               .where.not(modelo_id: nil).sum(:cantidad)
    item.cantidad_entrada = suma
  end

  # Utilizado en las vistas del valorado
  def self.suma_salidas(items, desde, hasta)
    item = items.first
    suma = -Transaccion.where(fecha: (desde..hasta),
                      subarticle_id: item.subarticle_id,
                      tipo: 'salida').sum(:cantidad)
    item.cantidad_salida = suma
  end

  def self.sumar_saldo_final(transacciones)
    entradas = salidas = 0
    transacciones.each do |transaccion|
      entradas += transaccion.items.sum(&:cantidad_entrada)
      salidas += transaccion.items.sum(&:cantidad_salida)
    end
    saldo_final = transacciones.last
    saldo_final.items.first.cantidad_salida = salidas
    saldo_final.items.last.cantidad_entrada = entradas
  end

  def self.generar_saldo_final(transacciones)
    entradas = salidas = 0
    importe_entradas = importe_salidas = 0
    transacciones.each do |transaccion|
      entradas += transaccion.items.sum(&:cantidad_entrada)
      salidas += transaccion.items.sum(&:cantidad_salida)
      importe_entradas += transaccion.items.sum(&:importe_entrada)
      importe_salidas += transaccion.items.sum(&:importe_salida)
    end
    saldo_final = transacciones.last
    saldo_final.items.first.cantidad_salida = salidas
    saldo_final.items.first.cantidad_entrada = entradas
    saldo_final.items.first.costo_unitario = nil
    saldo_final.items.first.importe_entrada_resumen = importe_entradas
    saldo_final.items.first.importe_salida_resumen = importe_salidas
  end

  def crear_items(saldos)
    # Limpiar campos
    saldos.each { |s| s.cantidad_entrada=0; s.cantidad_salida=0}
    # Verificar si es resta o adición
    if cantidad > 0
      # TODO hay que considerar el caso que haya otro con el mismo precio
      duplicado = self.dup
      duplicado.cantidad_entrada = duplicado.cantidad
      duplicado.cantidad_salida = 0
      duplicado.cantidad_saldo = duplicado.cantidad
      saldos << duplicado # Adicionar saldo
    else
      # Empezar a restar de los saldos
      numero = -cantidad
      saldos.each do |saldo|
        resto = saldo.cantidad_saldo - numero
        saldo.cantidad_entrada = 0
        if resto > 0
          saldo.cantidad_salida = numero
          saldo.cantidad_saldo = resto
          break
        else
          saldo.cantidad_salida = numero + resto
          saldo.cantidad_saldo = 0
          numero = -resto
        end
      end
    end

    # Eliminar aquellos saldos con entradas, salidas, y saldo igual a cero
    saldos.reject! do |saldo|
      saldo.cantidad_saldo.zero? &&
        saldo.cantidad_salida.zero? &&
        saldo.cantidad_entrada.zero?
    end

    self.items = saldos.length > 0 ? saldos : [Transaccion.new]
    saldos.map { |s| s.dup }
  end

  def importe_entrada
    if importe_entrada_resumen.nil?
      cantidad_entrada.to_f * costo_unitario.to_f
    else
      importe_entrada_resumen
    end
  end

  def importe_salida
    if importe_salida_resumen.nil?
      cantidad_salida.to_f * costo_unitario.to_f
    else
      importe_salida_resumen
    end
  end

  def importe_saldo
    if importe_saldo_resumen.nil?
      cantidad_saldo.to_f * costo_unitario.to_f
    else
      importe_saldo_resumen
    end
  end

  def nro_solicitud
    retorno = ''
    if self.nro_pedido.to_i != 0 && self.nro_pedido.present?
      retorno = self.nro_pedido
    end
    retorno
  end

  # Busca el precio unitario para las salidas de subatículos
  def precio_unitario
    subarticle.transacciones.saldo_al(self.fecha).first.costo_unitario rescue 0
  end

  def saldo
    cantidad
  end

  def saldo_inicial?
    !modelo_id.present?
  end

  private

    def inicializar
      self.cantidad ||= 0
      self.cantidad_entrada ||= 0
      self.cantidad_salida ||= 0
      self.cantidad_saldo ||= 0
      self.costo_unitario ||= 0
    end
end
