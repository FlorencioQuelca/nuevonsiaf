class KardexesController < ApplicationController
  include Fechas

  # GET /kardexes
  def index
    if params[:subarticle_id].present?
      @subarticle = Subarticle.find(params[:subarticle_id])

      @desde, @hasta = get_fechas(params)
      @transacciones = @subarticle.kardexs(@desde, @hasta)
      @year = @desde.year
    end
    respond_to do |format|
      format.html
      format.pdf do
        filename = @subarticle.description.parameterize || 'subarticulo'
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               # show_as_html: params.key?('debug'),
               template: 'kardexes/index.html.haml',
               orientation: 'Portrait',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end
end
