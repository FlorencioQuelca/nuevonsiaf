module Api
  module V2

    class ActivosController < ApiController
      include ApplicationHelper
      respond_to :json

      # GET /activos_funcionario
      def activos_funcionario
        mostrar_error_interno = false

        begin
          if params[:responsable_ci].present? && params[:usuario].present?
            unless params[:responsable_ci] == params[:usuario]
              # Verificar que el responsable de esta operación exista y este autorizada
              responsable_bd = User.where('ci = ? and (role = ? or role = ?)' , params[:responsable_ci].strip, 'admin', 'super_admin').first
              unless responsable_bd.present?
                mostrar_error_interno = true
                raise "El funcionario con ci: #{ params[:responsable_ci]} no existe en el sistema de almacenes/activos o su rol no tiene permisos para esta operación."
              end
            end

            asset = Asset.select('users.id, users.ci, assets.id, assets.description, assets.barcode, assets.observation, assets.observaciones, assets.precio,
              assets.detalle, assets.color, assets.marca, assets.modelo').joins(:user).where('users.ci = ?', params[:usuario])
            if asset.present?
              render json: { finalizado: true, mensaje: 'Lista de activos asignados al usuario.', data: asset }, root: false, status: 200
            else
              render json: { finalizado: true, mensaje: 'El usuario no tiene asignado activos.' }, root: false, status: 202
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

      # GET /buscar
      def buscar
        asset = nil
        code = 202
        validaciones = ""
        filtros = nil

        # a) ASIGNACIÓN DE ACTIVOS A FUNCIONARIO
        # b) INGRESO DE ACTIVO NUEVOS
        # c) BAJA DE ACTIVOS

        begin

          if params[:plantilla].present? and ['asignacion', 'ingreso', 'baja', 'reposicion'].include?(params[:plantilla]) and (params[:codigo].present? or params[:descripcion].present?)

            # Aplicar validaciones dependiendo la plantilla donde se use este servicio
            case params[:plantilla]
            when "asignacion"
              validaciones = "user_id is null and baja_id is null and ingreso_id is not null"
            when "ingreso"
              validaciones = "user_id is null and baja_id is null and ingreso_id is null"
            when "baja"
              validaciones = "baja_id is null"
            when "reposicion"
              validaciones = "baja_id is not null"
            end

            # Aplicar filtros
            if params[:codigo].present? && params[:descripcion].present?
              filtros = "(assets.barcode like '#{params[:codigo]}%' or assets.description like '%#{params[:descripcion]}%')"
            elsif params[:codigo].present?
              filtros = "assets.barcode like '#{params[:codigo]}%'"
            elsif params[:descripcion].present?
              filtros = "assets.description like '%#{params[:descripcion]}%'"
            end

            if filtros.present?
              filtros = "#{validaciones} and #{filtros}"
              asset = Asset.select('assets.id, assets.description, assets.barcode, assets.observation, assets.observaciones, assets.precio, assets.detalle, assets.color, assets.marca, assets.modelo, accounts.name as cuenta').joins(auxiliary: :account).where(filtros)
            end

            if asset.present?
              render json: { finalizado: true, mensaje: 'Proceso de búsqueda completado satisfactoriamente.', data: asset}, root: false, status: 200
            else
              render json: { finalizado: true, mensaje: 'No se encontraron activos con la informacion ingresada.' }, root: false, status: code
            end

          else
            render json: {finalizado: false, mensaje: 'Solicitud invalida.'}, root: false, status: 400
          end

        rescue StandardError => e
          Rails.logger.info e.message
          render json: { finalizado: false, mensaje: 'Ocurrio un error desconocido, contactese con el administrador del sistema.' }, root: false, status: 500
        end
      end

      # POST /devolucion - AODAF
      def devolucion
        mostrar_error_interno = false
        proceeding_type = Proceeding::PROCEEDING_TYPE.key("devolution")

        begin
          if params[:plantilla].present? && params[:plantilla][:id].present? && params[:plantilla][:responsable_ci].present? && params[:plantilla][:funcionario_ci].present? && params[:items].present? && (params[:items].is_a? Array)


            # Validar registro de devoluciones duplicado
            acta = Proceeding.where("JSON_EXTRACT(plantillas_info, '$.id_documento') = ?", params[:plantilla][:id]).first
            if acta.present?
              mostrar_error_interno = true
              raise "Ya existe un registro de devolución con el id de documento #{params[:plantilla][:id]}"
            end

            unless params[:plantilla][:responsable_ci] == params[:plantilla][:funcionario_ci]
              # Verificar que el responsable de esta operación exista y este autorizada (EDITOR)
              responsable_bd = User.where('ci = ? and (role = ? or role = ?)' , params[:plantilla][:responsable_ci].strip, 'admin', 'super_admin').first
              unless responsable_bd.present?
                mostrar_error_interno = true
                raise "El funcionario con ci: #{ params[:plantilla][:responsable_ci]} no existe en el sistema de almacenes/activos o su rol no tiene permisos para esta operación."
              end

              unless params[:devolucion_excepcional].present? && params[:devolucion_excepcional][:motivo].present? && params[:devolucion_excepcional][:referencia].present? && params[:devolucion_excepcional][:asunto].present?
                mostrar_error_interno = true
                raise "Debe especificar el motivo, referencia y asunto de la devolución excepcional"
              end
            end

            # Verificar que ningun activo este dado de baja
            cantidad_activos_con_baja = Asset.conbaja.where(id: params[:items]).count
            if cantidad_activos_con_baja > 0
              mostrar_error_interno = true
              raise "Uno o más activos estan dados de baja, verifique el estado de los activos."
            end

            # Validar  al beneficiario involucrado en la devolución
            beneficiario_bd = User.find_by(ci: params[:plantilla][:funcionario_ci])
            unless beneficiario_bd.present?
              mostrar_error_interno = true
              raise "No se encontro ningun funcionario con ci: #{params[:plantilla][:funcionario_ci]} en el sistema de almacenes/activos. Verifique que los datos enviados sean validos."
            end

            # Validar que los activos esten asignados y a la vez a la misma persona
            activos_validos = Asset.where(id: params[:items], user_id: beneficiario_bd.id)
            if (params[:items].count == activos_validos.count)
              plantillas_info = {
                cite: params[:plantilla][:cite],
                id_documento: params[:plantilla][:id]
              }
              unless params[:plantilla][:responsable_ci] == params[:plantilla][:funcionario_ci]
                plantillas_info[:motivo] = params[:devolucion_excepcional][:motivo]
                plantillas_info[:referencia] = params[:devolucion_excepcional][:referencia]
                plantillas_info[:asunto] = params[:devolucion_excepcional][:asunto]
              else
                responsable_bd = beneficiario_bd
              end

              unidad_beneficiario = beneficiario_bd.present? ? beneficiario_bd.department : nil
              unidad = responsable_bd.present? ? responsable_bd.department : nil
              usuario_info = {
                solicitado_por: {
                  id: ApplicationController.helpers.validar_valor_registro(beneficiario_bd, 'id'),
                  numero_documento: ApplicationController.helpers.validar_valor_registro(beneficiario_bd, 'ci'),
                  cargo: ApplicationController.helpers.validar_valor_registro(beneficiario_bd, 'title'),
                  unidad:ApplicationController.helpers.validar_valor_registro(unidad_beneficiario, 'name'),
                  email: ApplicationController.helpers.validar_valor_registro(beneficiario_bd, 'email')
                },
                realizado_por: {
                  id: ApplicationController.helpers.validar_valor_registro(responsable_bd, 'id'),
                  numero_documento: ApplicationController.helpers.validar_valor_registro(responsable_bd, 'ci'),
                  cargo: ApplicationController.helpers.validar_valor_registro(responsable_bd, 'title'),
                  unidad:ApplicationController.helpers.validar_valor_registro(unidad, 'name'),
                  email: ApplicationController.helpers.validar_valor_registro(responsable_bd, 'email')
                }
              }

              datos_acta_activos = {
                asset_ids: params[:items],
                user_id: beneficiario_bd.id,
                admin_id: responsable_bd.id,
                proceeding_type: proceeding_type,
                usuario_info: usuario_info.to_json,
                plantillas_info: plantillas_info.to_json
              }

              proceeding = Proceeding.new(datos_acta_activos)
              if proceeding.asset_ids.present? && proceeding.save
                render json: {
                  finalizado: true,
                  mensaje: 'La devolución de activos se ha procesado satisfactoriamente.',
                  pdf: proceedings_url + "/#{proceeding.id}.pdf",
                  id: proceeding.id
                }, root: false, status: 200
              else
                render json: { finalizado: false, mensaje: "Ocurrio un error al guardar la asignación, contactese con el administrador del sistema." }, root: false, status: 500
              end
            else
              render json: { finalizado: false, mensaje: 'Uno o más activos no estan asignados al mismo beneficiario', data:  activos_validos.ids }, root: false, status: 400
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

      # POST /asignacion
      def asignacion
        mostrar_error_interno = false
        proceeding_type = Proceeding::PROCEEDING_TYPE.key("assignation")

        begin
          if params[:id_documento].present? && params[:asset_ids].present? && (params[:asset_ids].is_a? Array) && params[:solicitante].present? && params[:admin_ci].present? && !params[:estado_usr_nuevo].nil?

            # Validar registro de asignaciones duplicado
            acta = Proceeding.where("JSON_EXTRACT(plantillas_info, '$.id_documento') = ?", params[:plantilla][:id]).first
            if acta.present?
              mostrar_error_interno = true
              raise "Ya existe un registro de asignación con el id de documento #{params[:plantilla][:id]}"
            end

            # Verificar que el responsable de esta operación exista y este autorizada
            responsable_bd = User.where('ci = ? and (role = ? or role = ?)' , params[:admin_ci].strip, 'admin', 'super_admin').first
            unless responsable_bd.present?
              mostrar_error_interno = true
              raise "El funcionario con ci: #{ params[:admin_ci]} no existe en el sistema de almacenes/activos o su rol no tiene permisos para esta operación."
            end

            # Verificar que ningun activo este dado de baja
            cantidad_activos_con_baja = Asset.conbaja.where(id: params[:asset_ids]).count
            if cantidad_activos_con_baja > 0
              mostrar_error_interno = true
              raise "Uno o más activos estan dados de baja, verifique la disponibilidad de los activos."
            end

            # Validar que los activos esten disponibles y tengan notas de ingreso
            cantidad_activos_validos = Asset.where(id: params[:asset_ids], user_id: nil).where.not(ingreso_id: nil).count
            unless (params[:asset_ids].count == cantidad_activos_validos)
              mostrar_error_interno = true
              raise "Uno o más activos ya estan asignados o no tienen las notas de ingreso, verifique la disponibilidad y notas de ingreso de los activos."
            end

            # Validar datos enviados del solicitante o beneficiario
            unless params[:solicitante][:nombres].present? && params[:solicitante][:apellidos].present? && params[:solicitante][:numero_documento].present? && params[:solicitante][:email].present? && params[:solicitante][:cargo].present? && params[:solicitante][:unidad].present?
              mostrar_error_interno = true
              raise 'Los datos del beneficiario son invalidos. Debe enviar todos los datos requeridos.'
            end

            beneficiario_bd_id, mensaje = User.emparejar_usuario(params[:solicitante])
            unless beneficiario_bd_id.present?
              mostrar_error_interno = true
              raise mensaje
            end

            unidad = responsable_bd.present? ? responsable_bd.department : nil
            usuario_info = {
              solicitado_por: {
                id: beneficiario_bd_id,
                numero_documento: ApplicationController.helpers.validar_valor(params[:solicitante][:numero_documento]),
                cargo: ApplicationController.helpers.validar_valor(params[:solicitante][:cargo]),
                unidad: ApplicationController.helpers.validar_valor(params[:solicitante][:unidad]),
                email: ApplicationController.helpers.validar_valor(params[:solicitante][:email])
              },
              realizado_por: {
                id: ApplicationController.helpers.validar_valor_registro(responsable_bd, 'id'),
                numero_documento: ApplicationController.helpers.validar_valor_registro(responsable_bd, 'ci'),
                cargo: ApplicationController.helpers.validar_valor_registro(responsable_bd, 'title'),
                unidad:ApplicationController.helpers.validar_valor_registro(unidad, 'name'),
                email: ApplicationController.helpers.validar_valor_registro(responsable_bd, 'email')
              }
            }

            plantillas_info = {
              cite: params[:cite],
              id_documento: params[:id_documento]
            }
            datos_acta_activos = {
              asset_ids: params[:asset_ids],
              user_id: beneficiario_bd_id,
              admin_id: responsable_bd.id,
              proceeding_type: proceeding_type,
              usuario_info: usuario_info.to_json,
              plantillas_info: plantillas_info.to_json
            }
            proceeding = Proceeding.new(datos_acta_activos)
            if proceeding.asset_ids.present? && proceeding.save
              render json: {
                finalizado: true,
                mensaje: 'La asignación se ha procesado satisfactoriamente.',
                pdf: proceedings_url + "/#{proceeding.id}.pdf",
                id: proceeding.id
              }, root: false, status: 200
            else
              render json: { finalizado: false, mensaje: "Ocurrio un error al guardar la asignación, contactese con el administrador del sistema." }, root: false, status: 500
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

      # POST /crear_nuevo_ingreso
      def crear_nuevo_ingreso
        mostrar_error_interno = false

        begin

          if params[:plantilla].present? && params[:plantilla][:id].present? && params[:cabecera].present? && params[:cabecera][:tipo_ingreso].present? && ['compra', 'donacion_transferencia', 'reposicion'].include?(params[:cabecera][:tipo_ingreso]) && params[:items].present? && (params[:items].is_a? Array)

            # Validar el registro de notas de ingreso duplicados
            ingreso = Ingreso.find_by(documento_id: params[:plantilla][:id].to_i)
            if ingreso.present?
              mostrar_error_interno = true
              raise "Ya existe una nota de ingreso con el id de documento #{params[:plantilla][:id]}"
            end

            # Verificar que el responsable de esta operación exista y este autorizada(rol)
            responsable_plantillas = User.where('ci = ? and (role = ? or role = ?)' , params[:plantilla][:responsable_ci].strip, 'admin', 'super_admin').first
            unless responsable_plantillas.present?
              mostrar_error_interno = true
              raise "El funcionario con ci: #{ params[:plantilla][:responsable_ci]} no existe en el sistema de almacenes/activos o su rol no tiene permisos para esta operación."
            end

            # Validar que los activos a ingresar sean nuevos y no hayan sido registrado en otro ingreso previo
            cantidad_activos_validos = Asset.where(id: params[:items], user_id: nil, ingreso_id: nil, baja_id: nil).count
            unless (params[:items].count == cantidad_activos_validos)
              mostrar_error_interno = true
              raise "Los activos a ingresar no son validos, verifique que los activos no cuenten con nota de ingreso y no esten asignados a algun funcionario."
            end

            nota_ingreso = Ingreso.new
            nota_ingreso.tipo_ingreso = params[:cabecera][:tipo_ingreso]
            case params[:cabecera][:tipo_ingreso]
            when 'compra'
              fecha = Date.parse(params[:cabecera][:factura_fecha]) rescue nil
              unless fecha.present?
                mostrar_error_interno = true
                raise "El formato de la fecha de factura es invalido."
              end

              nota_ingreso.supplier_id = params[:cabecera][:proveedor_id]
              nota_ingreso.factura_numero = params[:cabecera][:factura_numero]
              nota_ingreso.factura_autorizacion = params[:cabecera][:factura_autorizacion]
              nota_ingreso.factura_fecha = params[:cabecera][:factura_fecha]
              nota_ingreso.nota_entrega_numero = params[:cabecera][:nota_entrega_numero]
              nota_ingreso.nota_entrega_fecha = params[:cabecera][:nota_entrega_fecha]
              nota_ingreso.c31_numero = params[:cabecera][:requerimiento_numero]
              nota_ingreso.c31_fecha = params[:cabecera][:requerimiento_fecha]

            when 'donacion_transferencia'
              fecha = Date.parse(params[:cabecera][:documento_respaldo_fecha]) rescue nil
              unless fecha.present?
                mostrar_error_interno = true
                raise "El formato de la fecha del documento de respaldo es invalido."
              end

              nota_ingreso.entidad_donante = params[:cabecera][:entidad_donante]
              nota_ingreso.factura_numero = params[:cabecera][:documento_respaldo]
              nota_ingreso.factura_fecha = params[:cabecera][:documento_respaldo_fecha]

            when 'reposicion'
              fecha = Date.parse(params[:cabecera][:documento_respaldo_fecha]) rescue nil
              unless fecha.present?
                mostrar_error_interno = true
                raise "El formato de la fecha del documento de respaldo es invalido."
              end

              activo_a_reponer = Asset.where(id: params[:cabecera][:item_a_reponer]).where.not(baja_id: nil).first

              unless activo_a_reponer.present?
                mostrar_error_interno = true
                raise "El activo a reponer no existe o aún no esta dado de baja"
              end

              nota_ingreso.factura_numero = params[:cabecera][:documento_respaldo]
              nota_ingreso.factura_fecha = params[:cabecera][:documento_respaldo_fecha]

            else
              mostrar_error_interno = true
              raise "Tipo de ingreso inválido"
            end

            nota_ingreso.total = params[:total].to_f
            nota_ingreso.observacion = params[:cabecera][:observaciones]

            nota_ingreso.asset_ids = params[:items]

            nota_ingreso.user_id = responsable_plantillas.id
            nota_ingreso.documento_id = params[:plantilla][:id]
            nota_ingreso.documento_cite = params[:plantilla][:cite]

            if nota_ingreso.save
              if params[:cabecera][:tipo_ingreso] == 'reposicion'
                # Guardar historico
                Asset.where(id: params[:items]).update_all(asset_id: params[:item_a_reponer])
              end
              render json: {finalizado: true, mensaje: 'Ingreso almacenado satisfactoriamente.', id: nota_ingreso.id, numero: nota_ingreso.numero}, root: false, status: 200
            else
              render json: {finalizado: false, mensaje: 'Ocurrio un error al guardar el ingreso, verifique los datos de envio.'}, root: false, status: 500
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

      # POST /baja
      def baja
        mostrar_error_interno = false

        begin

          if params[:plantilla].present? && params[:plantilla][:id].present? && params[:cabecera].present? && params[:items].present? && (params[:items].is_a? Array)

            # Validar el registro de bajas duplicados
            baja = Baja.find_by(documento_id: params[:plantilla][:id].to_i)
            if baja.present?
              mostrar_error_interno = true
              raise "Ya existe una nota de baja con el id de documento #{params[:plantilla][:id]}"
            end

            # Verificar que el responsable de esta operación exista y este autorizada(rol)
            responsable_plantillas = User.where('ci = ? and (role = ? or role = ?)' , params[:plantilla][:responsable_ci].strip, 'admin', 'super_admin').first
            unless responsable_plantillas.present?
              mostrar_error_interno = true
              raise "El funcionario con ci: #{ params[:plantilla][:responsable_ci]} no existe en el sistema de almacenes/activos o su rol no tiene permisos para esta operación."
            end

            # Validar formato de fecha de la baja
            fecha_baja = Date.parse(params[:cabecera][:fecha]) rescue nil
            unless fecha_baja.present?
              mostrar_error_interno = true
              raise "El formato de la fecha de la baja es invalido."
            end

            # Validar que los activos existan y no esten dado de baja
            cantidad_activos_validos = Asset.where(id: params[:items], baja_id: nil).count
            unless (params[:items].count == cantidad_activos_validos)
              mostrar_error_interno = true
              raise "Los activos que se darán de baja no son validos, verifique que los activos existan y esten vigentes."
            end

            baja = Baja.new

            baja.motivo = params[:cabecera][:causal]
            baja.fecha = params[:cabecera][:fecha]
            baja.documento = params[:cabecera][:disposicion_respaldo]
            baja.observacion = params[:cabecera][:observaciones]
            baja.user_id = responsable_plantillas.id

            baja.documento_id = params[:plantilla][:id]
            baja.documento_cite = params[:plantilla][:cite]

            baja.asset_ids = params[:items]

            if baja.save
              render json: {finalizado: true, mensaje: 'La baja fue registrado satisfactoriamente.', id: baja.id, numero: baja.numero}, root: false, status: 200
            else
              render json: {finalizado: false, mensaje: 'Ocurrio un error al guardar la baja de activos, verifique los datos de envio.'}, root: false, status: 500
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

      # GET /ubicaciones
      def ubicaciones
        begin
          render json: { finalizado: true, mensaje: 'Ubicaciones disponibles.', data: get_ubicaciones }, root: false, status: 200
        rescue StandardError => e
          Rails.logger.info e.message
          render json: { finalizado: false, mensaje: 'Ocurrio un error desconocido, contactese con el administrador del sistema.' }, root: false, status: 500
        end
      end

      # GET /auxiliares
      def auxiliares
        begin
          render json: { finalizado: true, mensaje: 'Auxiliares disponibles.', data: status_active(Auxiliary) }, root: false, status: 200
        rescue StandardError => e
          Rails.logger.info e.message
          render json: { finalizado: false, mensaje: 'Ocurrio un error desconocido, contactese con el administrador del sistema.' }, root: false, status: 500
        end
      end

      # GET /estados
      def estados
        begin
          render json: { finalizado: true, mensaje: 'Estados disponibles.', data: Asset::STATE }, root: false, status: 200
        rescue StandardError => e
          Rails.logger.info e.message
          render json: { finalizado: false, mensaje: 'Ocurrio un error desconocido, contactese con el administrador del sistema.' }, root: false, status: 500
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

    end
  end
end
