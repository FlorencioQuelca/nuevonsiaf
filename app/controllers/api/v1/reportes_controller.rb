module Api
  module V1
    class ReportesController < ApplicationController
      include Fechas

      def activos
        desde, hasta = get_fechas(params, false)
        cuenta = params[:cu]
        @activos =
          if params[:col].present?
            columna = params[:col]
            q = params[:q]
            Asset.busqueda_basica(columna, q, cuenta, desde, hasta).order(:code)
          else
            codigo = params[:co]
            numero_factura = params[:nf]
            descripcion = params[:de]
            precio = params[:pr]
            ubicacion = params[:ub]
            Asset.busqueda_avanzada(codigo, numero_factura, descripcion, cuenta, precio, desde, hasta, ubicacion).order(:code)
          end
        @total = @activos.inject(0.0) { |total, activo| total + activo.precio }
        respond_to do |format|
          format.json do
            if @activos.present?
              render json: {activos: (ActiveModel::ArraySerializer.new(@activos, each_serializer: ActivoSerializer, root: false)), total: @total},
                     status: 200
            else
              render json: { mensaje: 'No se tienen activos.', activos: [], total: nil },
                     status: 200
            end
          end
          format.pdf do
            filename = 'reporte-de-activos'
            render pdf: filename,
                   disposition: 'attachment',
                   layout: 'pdf.html',
                   template: 'reportes/activos.html.haml',
                   orientation: 'Portrait',
                   page_size: 'Letter',
                   margin: view_context.margin_pdf,
                   header: { html: { template: 'shared/header.pdf.haml' } },
                   footer: { html: { template: 'shared/footer.pdf.haml' } }
          end
        end
      end
    end
  end
end
