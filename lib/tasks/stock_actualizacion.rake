namespace :db do
  ##
  # Esta tarea es para igualar las sumatoria de entry_subarticles y coincida
  # con el stock disponible del subarticulo, esto para los subarticulos que
  # tengan esta diferencia.
  # uso: rake db:stock_update
  desc 'Actualización de los subarticulos que tengan la diferencia en el stock y la sumatoria de entry_subarticles'
  task stock_actualizacion: :environment do
    archivo = File.new('stock_update.txt', 'w')
    archivo_csv = File.new('stock_update.csv', 'w')
    texto = ''
    cantidad_stock_mayor = 0
    cantidad_stock_menor = 0
    cantidad_stock_cero = 0
    subarticulos_con_diferencia = Subarticle.all.select{ |s| s.stock != s.entry_subarticles_exist.sum(:stock) }
    texto = "Cantidad de subarticulos que serán afectados: #{subarticulos_con_diferencia.size}"
    mostrar_escribir(archivo, texto)
    subarticulos_con_diferencia.each_with_index do |subarticulo, i|
      texto = "#{i + 1}. -------------------------------"
      mostrar_escribir(archivo, texto)
      texto = '---------Antes del cambio---------'
      mostrar_escribir(archivo, texto)
      texto = "subarticle_id: #{subarticulo.id}"
      mostrar_escribir(archivo, texto)
      texto = "Stock: #{subarticulo.stock}"
      mostrar_escribir(archivo, texto)
      texto = "Sumatoria entry_subarticles: #{subarticulo.entry_subarticles_exist.sum(:stock)}"
      mostrar_escribir(archivo, texto)
      texto = "Transacciones: #{subarticulo.transacciones.pluck(:cantidad)}"
      mostrar_escribir(archivo, texto)
      texto = "Entry_subarticles: #{subarticulo.entry_subarticles_exist.map{|es| { id: es.id, stock: es.stock }}}"
      mostrar_escribir(archivo, texto)
      texto = "Cantidad entry_subarticles: #{subarticulo.entry_subarticles_exist.size}"
      mostrar_escribir(archivo, texto)
      if subarticulo.stock.zero?
        subarticulo.entry_subarticles_exist.each do |ent_sub|
          archivo_csv.puts(linea_csv(ent_sub.id, ent_sub.stock, 0))
          ent_sub.stock = 0
          ent_sub.save
        end
      else
        if subarticulo.stock > subarticulo.entry_subarticles_exist.sum(:stock)
          cantidad_stock_mayor += 1
        else
          cantidad_stock_menor += 1
        end
        igualar_stock_entry_subarticle(subarticulo, archivo_csv)
      end
      cantidad_stock_cero += 1 if subarticulo.stock.zero?
      texto = '---------Después del cambio---------'
      mostrar_escribir(archivo, texto)
      texto = "subarticle_id: #{subarticulo.id}"
      mostrar_escribir(archivo, texto)
      texto = "Stock: #{subarticulo.stock}"
      mostrar_escribir(archivo, texto)
      texto = "Sumatoria entry_subarticles: #{subarticulo.entry_subarticles_exist.sum(:stock)}"
      mostrar_escribir(archivo, texto)
      texto = "Transacciones: #{subarticulo.transacciones.pluck(:cantidad)}"
      mostrar_escribir(archivo, texto)
      texto = "Entry_subarticles: #{subarticulo.entry_subarticles_exist.map{|es| { id: es.id, stock: es.stock }}}"
      mostrar_escribir(archivo, texto)
      texto = "Cantidad entry_subarticles: #{subarticulo.entry_subarticles_exist.size}"
      mostrar_escribir(archivo, texto)
    end
    texto = '=================================='
    mostrar_escribir(archivo, texto)
    texto = "Stock mayor a la sumatoria entry_subarticles: #{cantidad_stock_mayor}"
    mostrar_escribir(archivo, texto)
    texto = "Stock menor a la sumatoria entry_subarticles: #{cantidad_stock_menor}"
    mostrar_escribir(archivo, texto)
    texto = "Stock igual a cero: #{cantidad_stock_cero}"
    mostrar_escribir(archivo, texto)
    subarticulos_con_diferencia = Subarticle.all.select { |s| s.stock != s.entry_subarticles_exist.sum(:stock) }.size
    texto = "Actualement existen #{subarticulos_con_diferencia} subarticulo que tienen diferencia entre el stock y la sumatoria de entry_subarticles."
    mostrar_escribir(archivo, texto)
    archivo.close
    archivo_csv.close
  end

  # Metodo que muestra y guarda un texto en un archivo.
  def mostrar_escribir(archivo, texto)
    puts texto
    archivo.puts(texto)
  end

  #metodo que iguala el stock con los entry_subarticles.
  def igualar_stock_entry_subarticle(subarticulo, archivo_csv)
    if subarticulo.entry_subarticles_exist.size == 1
      primer_entry_subarticle = subarticulo.entry_subarticles_exist.first
      if primer_entry_subarticle.present?
        archivo_csv.puts(linea_csv(primer_entry_subarticle.id, primer_entry_subarticle.stock, subarticulo.stock))
        primer_entry_subarticle.stock = subarticulo.stock
        primer_entry_subarticle.save
      end
    else
      if subarticulo.entry_subarticles_exist.present?
        loop do
          entries_subarticles = subarticulo.entry_subarticles_exist
          primer_entry_subarticle = entries_subarticles.first
          if primer_entry_subarticle.present?
            sumatoria_sin_primero = entries_subarticles.sum(:stock) - primer_entry_subarticle.stock
            saldo = subarticulo.stock - sumatoria_sin_primero
            if saldo >= 0
              archivo_csv.puts(linea_csv(primer_entry_subarticle.id, primer_entry_subarticle.stock, saldo))
              primer_entry_subarticle.stock = saldo
              primer_entry_subarticle.save
              break
            else
              archivo_csv.puts(linea_csv(primer_entry_subarticle.id, primer_entry_subarticle.stock, 0))
              primer_entry_subarticle.stock = 0
              primer_entry_subarticle.save
            end
          else
            break
          end
        end
      else
        entries_subarticles = subarticulo.entry_subarticles
        primer_entry_subarticle = entries_subarticles.last
        if primer_entry_subarticle.present?
          archivo_csv.puts(linea_csv(primer_entry_subarticle.id, primer_entry_subarticle.stock, subarticulo.stock))
          primer_entry_subarticle.stock = subarticulo.stock
          primer_entry_subarticle.save
        end
      end
    end
  end

  def linea_csv(id, antiguo_stock, nuevo_stock)
    "#{id},#{antiguo_stock},#{nuevo_stock}"
  end
end
