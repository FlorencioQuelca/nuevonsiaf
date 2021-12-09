module Api
  module V2

    class AlmacenesController < ApiController
      respond_to :json

      # GET /articulos
      def articulos
        if params[:descripcion].present?
          todos = (params[:todos].present? and params[:todos].to_i == 1) ? true : false
          render json: {finalizado: true, mensaje: 'Consulta obtenida satisfactoriamente.', items: Subarticle.buscar_articulo(params[:descripcion], todos)}, root: false, status: 200
        else
          render json: {finalizado: false, mensaje: 'Solicitud invalida.'}, root: false, status: 400
        end
      end

      # POST /crear_solicitud
      def crear_solicitud
        mostrar_error_interno = false
        begin
          if params[:solicitante].present? and params[:items].present? and params[:id].present?
            persona_bd_id, mensaje = User.emparejar_usuario(params[:solicitante])

            if persona_bd_id.present?
              req = Request.find_by(documento_id: params[:id].to_i)

              if req.present?
                mostrar_error_interno = true
                raise "En almacenes ya existe una solicitud con el id de documento #{params[:id]}"
              end

              solicitud = Request.new
              solicitud.created_at = DateTime.now
              # solicitud.admin_id = nil # usuario que registra la solicitud
              solicitud.user_id = persona_bd_id # usuario beneficiario(quien ha de recibir los items solicitados)
              solicitud.status = 'initiation'

              # Guardar datos de usuarios involucrados por temas de cambio de cargo o unidad

              solicitud.documento_id = params[:id]
              nombre_persona_plantillas = "#{params[:solicitante][:nombres]} #{params[:solicitante][:apellidos]}".strip
              solicitud.json_usuarios = {solicitado_por: {id: persona_bd_id, nombre: ApplicationController.helpers.validar_valor(nombre_persona_plantillas), numero_documento: ApplicationController.helpers.validar_valor(params[:solicitante][:numero_documento]), cargo: ApplicationController.helpers.validar_valor(params[:solicitante][:cargo]), unidad: ApplicationController.helpers.validar_valor(params[:solicitante][:unidad]), email: ApplicationController.helpers.validar_valor(params[:solicitante][:email])}}.to_json

              # items solicitados

              items = []
              params[:items].each do |item|
                if item[:cantidad].to_i <= 0
                  mostrar_error_interno = true
                  raise "Cantidades inválidas, verifique que las cantidades sean mayores a cero."
                end
                items << {subarticle_id: item[:id], amount: item[:cantidad]}
              end
              solicitud.subarticle_requests_attributes = items

              if solicitud.save
                render json: {finalizado: true, mensaje: 'Solicitud almacenada satisfactoriamente.', id: solicitud.id, numero: solicitud.nro_solicitud}, root: false, status: 200
              else
                render json: {finalizado: false, mensaje: 'Ocurrio un error al guardar la solicitud, verifique los datos de envio.'}, root: false, status: 500
              end
            else
              render json: {finalizado: false, mensaje: mensaje}, root: false, status: 400
            end
          else
            render json: {finalizado: false, mensaje: 'Solicitud invalida.'}, root: false, status: 400
          end
        rescue StandardError => e
          Rails.logger.info e.message
          msg = mostrar_error_interno ? e.message : 'Ocurrio un error desconocido, contactese con el administrador del sistema.'
          render json: {finalizado: false, mensaje: msg}, root: false, status: 500
        end
      end

      # PATCH/PUT /actualizar_solicitud
      def actualizar_solicitud
        begin
          if params[:id].present? and params[:cite_sms].present? and params[:cite_ems].present?
            solicitud = Request.find_by(id: params[:id], status: 'delivered')
            if solicitud.present?
              if solicitud.cite_sms.nil? and solicitud.cite_ems.nil?
                if solicitud.update_attributes(cite_sms: params[:cite_sms], cite_ems: params[:cite_ems])
                  render json: {finalizado: true, mensaje: 'Solicitud actualizada satisfactoriamente.'}, root: false, status: 200
                else
                  render json: {finalizado: false, mensaje: 'Ocurrio un error al actualizar la solicitud, verifique los datos de envio.'}, root: false, status: 500
                end
              else
                render json: {finalizado: false, mensaje: 'La solicitud ya fue actualizada.'}, root: false, status: 400
              end
            else
              render json: {finalizado: false, mensaje: 'La solicitud no existe o no ha sido procesada en almacenes.'}, root: false, status: 400
            end
          else
            render json: {finalizado: false, mensaje: 'Solicitud invalida.'}, root: false, status: 400
          end
        rescue StandardError => e
          Rails.logger.info e.message
          render json: {finalizado: false, mensaje: 'Ocurrio un error desconocido, contactese con el administrador del sistema.'}, root: false, status: 500
        end
      end

      # GET /obtener_solicitud
      def obtener_solicitud
        if params[:id].present?
          solicitud = Request.find_by(id: params[:id], status: 'delivered')
          if solicitud.present?
            if solicitud.cite_sms.nil? and solicitud.cite_ems.nil?
              subarticulos_solicitados_aprobados = SubarticleRequest.select('subarticles.id, subarticles.code, subarticles.description, subarticles.unit, subarticle_requests.amount, subarticle_requests.amount_delivered').joins(:subarticle).where(request_id: params[:id])
              items = []
              subarticulos_solicitados_aprobados.each do |item|
                items << {id: item[:id], codigo: item[:code], descripcion: item[:description], unidad: item[:unit], cantidad_solicitada: item[:amount].to_f, cantidad_entregada: item[:amount_delivered].to_f}
              end
              render json: {finalizado: true, datos: {cabecera:{nro_solicitud: solicitud.nro_solicitud, fecha_entrega: (solicitud.delivery_date.present? ? I18n.l(solicitud.delivery_date.to_date) : nil ), entregado_por: solicitud.admin_name}, items: items}, mensaje: 'Solicitud procesada satisfactoriamente.'}, root: false, status: 200
            else
              render json: {finalizado: false, mensaje: 'La solicitud ya tiene cites establecidos.'}, root: false, status: 400
            end
          else
            render json: {finalizado: false, mensaje: 'La solicitud no existe o no ha sido procesada.'}, root: false, status: 400
          end
        else
          render json: {finalizado: false, mensaje: 'Solicitud invalida.'}, root: false, status: 400
        end
      end

      # GET /proveedores
      def proveedores
        if params[:descripcion].present?
          proveedores = Supplier.select('id, name as nombre, nit').where("name LIKE ?", "%#{params[:descripcion]}%")
          render json: {finalizado: true, mensaje: 'Consulta obtenida satisfactoriamente.', datos: proveedores}, root: false, status: 200
        else
          render json: {finalizado: false, mensaje: 'Solicitud invalida.'}, root: false, status: 400
        end
      end

      # POST /crear_nota_ingreso
      def crear_nuevo_ingreso
        mostrar_error_interno = false

        begin
          if params[:plantilla].present? && params[:plantilla][:id].present? && params[:responsable].present? && params[:cabecera].present? && params[:cabecera][:tipo_ingreso].present? && ['compra', 'donacion_transferencia', 'reingreso'].include?(params[:cabecera][:tipo_ingreso]) && params[:detalle].present? && params[:detalle][:items].present?

            #Validar duplicidad de la nota de ingreso
            ingreso = NoteEntry.find_by(documento_id: params[:plantilla][:id].to_i)
            if ingreso.present?
              mostrar_error_interno = true
              raise "En almacenes ya existe una nota de ingreso con el id de documento #{params[:plantilla][:id]}"
            end

            # Verificar que el responsable de esta operación exista y este autorizada(rol)
            responsable_plantillas = User.where('ci = ? and (role = ? or role = ? or role = ?)' , params[:responsable][:numero_documento].strip, 'admin', 'super_admin', 'admin_store').first
            unless responsable_plantillas.present?
              mostrar_error_interno = true
              raise "El funcionario con ci: #{ params[:responsable][:numero_documento]} no existe en el sistema de almacenes/activos o su rol no tiene permisos para esta operación."
            end

            if !(params[:detalle][:subtotal].present? and params[:detalle][:descuento].present? and params[:detalle][:total].present?)
              mostrar_error_interno = true
              raise "El monto subtotal, descuento o total tiene datos inválidos."
            end

            nota_entrada = NoteEntry.new
            cabecera = params[:cabecera]
            nota_entrada.tipo_ingreso = cabecera[:tipo_ingreso]
            case cabecera[:tipo_ingreso]
            when 'compra'

              proveedor = Supplier.find(cabecera[:proveedor])
              unless proveedor.present?
                mostrar_error_interno = true
                raise "No existe el proveedor #{cabecera[:proveedor]}. Si es nuevo, debe registrarlo previamente en almacenes."
              end

              fecha = Date.parse(cabecera[:factura_fecha]) rescue nil
              unless fecha.present?
                mostrar_error_interno = true
                raise "La fecha de factura es inválido"
              end

              nota_entrada.supplier_id = proveedor.present? ? proveedor.id : nil
              nota_entrada.c31 = cabecera[:c31]
              nota_entrada.c31_fecha = cabecera[:c31_fecha]
              nota_entrada.delivery_note_number = cabecera[:nota_entrega_numero]
              nota_entrada.delivery_note_date = cabecera[:nota_entrega_fecha]
              nota_entrada.invoice_number = cabecera[:factura_numero]
              nota_entrada.invoice_autorizacion = cabecera[:factura_autorizacion]
              nota_entrada.invoice_date = cabecera[:factura_fecha]

            when 'donacion_transferencia'
              fecha = Date.parse(cabecera[:documento_respaldo_fecha]) rescue nil
              unless fecha.present?
                mostrar_error_interno = true
                raise "El formato de la fecha de respaldo es invalido."
              end

              nota_entrada.entidad_donante = cabecera[:entidad_donante]
              nota_entrada.invoice_number = cabecera[:documento_respaldo]
              nota_entrada.invoice_date = cabecera[:documento_respaldo_fecha]

            when 'reingreso'
              fecha = Date.parse(cabecera[:documento_respaldo_fecha]) rescue nil
              unless fecha.present?
                mostrar_error_interno = true
                raise "El formato de la fecha de respaldo es invalido."
              end

              nota_entrada.invoice_number = cabecera[:documento_respaldo]
              nota_entrada.invoice_date = cabecera[:documento_respaldo_fecha]
              nota_entrada.reingreso = 1

            else
              mostrar_error_interno = true
              raise "Tipo de ingreso inválido"
            end

            # Items a ingresar
            items = []
            costo_total_nota_ingreso = 0.0
            params[:detalle][:items].each do |item|
              # costo_total_item =  item[:cantidad].to_f * item[:precio].to_f
              # costo_total_nota_ingreso = costo_total_nota_ingreso + costo_total_item

              if !(item[:id].present? and item[:cantidad].present? and item[:precio].present? and item[:total].present?)
                mostrar_error_interno = true
                raise "Los items tienen datos incompletos o inválidos."
              end

              items << {subarticle_id: item[:id], amount: item[:cantidad], unit_cost: item[:precio], total_cost: item[:total].to_f}
            end
            nota_entrada.subtotal = params[:detalle][:subtotal].to_f # costo_total_nota_ingreso
            nota_entrada.descuento = params[:detalle][:descuento].to_f
            nota_entrada.total = params[:detalle][:total].to_f # costo_total_nota_ingreso - nota_entrada.descuento
            nota_entrada.entry_subarticles_attributes = items
            nota_entrada.user_id = responsable_plantillas.id
            nota_entrada.documento_id = params[:plantilla][:id]
            nota_entrada.documento_cite = params[:plantilla][:cite]
            nota_entrada.observacion = params[:cabecera][:observaciones]

            if nota_entrada.save
              render json: {finalizado: true, mensaje: "Ingreso almacenado satisfactoriamente.", id: nota_entrada.id, numero: nota_entrada.nro_nota_ingreso}, root: false, status: 200
            else
              render json: {finalizado: false, mensaje: "Ocurrio un error al guardar el ingreso, verifique los datos de envio."}, root: false, status: 500
            end

          else
            render json: {finalizado: false, mensaje: 'Solicitud invalida.'}, root: false, status: 400
          end
        rescue StandardError => e
          Rails.logger.info e.message
          msg = mostrar_error_interno ? e.message : 'Ocurrio un error desconocido, contactese con el administrador del sistema.'
          render json: {finalizado: false, mensaje: msg }, root: false, status: 500
        end
      end

    end

  end
end
