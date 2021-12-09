module Api
  module V2
    module Almacenes
      class ReportesController < ApplicationController
        skip_before_action :verify_authenticity_token

        respond_to :json

        #patch ingresos(note_entries)
        def fisico_valorado
          datos, mensaje = Material.reporte_fisico_valorado(fisico_valorado_params["cuenta_ids"], fisico_valorado_params["fecha_inicio"], fisico_valorado_params["fecha_fin"], fisico_valorado_params["ceros"])
          render json: formato_respuesta(true, mensaje, datos)
        end

        def fisico_valorado_pdf
          @reporte = params[:reporte]
          @fecha_desde = params[:fecha_desde]
          @fecha_hasta = params[:fecha_hasta]
          @tipo = params[:tipo]
          filename = 'inventario-fisico-valorado'
          respond_to do |format|
            format.pdf do
              render pdf: filename,
                     disposition: 'attachment',
                     layout: 'pdf.html',
                     template: 'materials/fisico_valorado_v2.html.haml',
                     page_size: 'Letter',
                     orientation: 'Landscape',
                     margin: view_context.margin_pdf,
                     header: { html: { template: 'shared/header.pdf.haml' } },
                     footer: { html: { template: 'shared/footer.pdf.haml' } }
            end
          end
        end

        def fisico_valorado_ods_csv
          reporte = params[:reporte]
          tipo = params[:tipo]
          reporte_configuracion = Material.prepara_hoja_calculo(reporte, tipo)
          respond_to do |format|
            format.csv { render csv: SpreadsheetArchitect::to_csv(reporte_configuracion), filename: "fisico_valorado" }
            format.ods { render ods: SpreadsheetArchitect::to_ods(reporte_configuracion), filename: "fisico_valorado" }
          end
        end

        private

        def fisico_valorado_params
          params.require(:fisico_valorado).permit(:ceros, :fecha_inicio, :fecha_fin, :tipo, :cuenta_ids => [])
        end
      end
    end
  end
end
