require 'raw_sql'

class ReportesController < ApplicationController
  # load_and_authorize_resource
  include Fechas

  def kardex
    @desde, @hasta = get_fechas(params)
    @subarticles = Subarticle.con_saldo_y_movimientos_en(@desde, @hasta)
                             .order(:code)
    respond_to do |format|
      format.html
      format.pdf do
        # Eliminar archivos PDF existentes
        Dir['tmp/*.pdf'].each { |a| File.delete(a) }
        # Generar los archivos PDF
        @subarticles.each do |subarticle|
          @subarticle = subarticle

          @datos_kardex = @subarticle.obtiene_kardex_v2(@desde, @hasta)

          nombre_archivo = "#{subarticle.barcode}_#{view_context.dom_id(subarticle)}.pdf"

          pdf = render_to_string(
            pdf: nombre_archivo,
            layout: 'pdf.html',
            template: 'subarticles/kardex_v2.html.haml',
            orientation: 'Portrait',
            page_size: 'Letter',
            margin: view_context.margin_pdf,
            header: {html: {template: 'shared/header.pdf.haml'}},
            footer: {html: {template: 'shared/footer.pdf.haml'}}
          )
          save_path = Rails.root.join('tmp', nombre_archivo)
          File.open(save_path, 'wb') do |file|
            file << pdf
          end
        end
        archivo_zip = comprimir_a_zip(@desde, @hasta)
        send_data(File.open(archivo_zip).read, type: 'application/zip', disposition: 'attachment')
        File.delete archivo_zip if File.exist?(archivo_zip)
      end
    end
  end

  # Reporte para activos fijos
  def activos
    @columnas = %w(all code invoice description)
    @columnas = @columnas.map { |c| {descripcion: t("activerecord.attributes.asset.#{c}"), clave: c } }
    @cuentas = Account.all
    @cuentas = [{ descripcion: "Seleccionar cuenta", clave: ""}] + @cuentas.order(:code).map { |b| {descripcion: b.code_and_name, clave: b.id, } }
    respond_to do |format|
      format.html
    end
  end

  # Reporte de salidas de almacenes por cuenta contable
  def cuenta_contable
    @hasta = get_fechas(params)[1]
    @materials = Material.cuenta_contable(@hasta)
    @totales = Material.cuenta_contable_total(@hasta)
    filename = "entradas-y-salidas-valorado-al-#{@hasta.to_date}"
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: filename,
               disposition: 'inline',
               layout: 'pdf.html',
               template: 'reportes/cuenta_contable.html.haml',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # Depreciación de activos fijos - reporte 10 vSIAF
  def depreciacion
    @desde, @hasta = get_fechas(params)
    cuentas = params[:cuentas]
    @cuentas = Account
    @cuentas = @cuentas.where(id: cuentas) if cuentas.present?
    if @desde && @hasta
      @cuentas = @cuentas.joins(auxiliaries: {assets: :ingreso})
                        .where('ingresos.factura_fecha' => @desde..@hasta)
                        .uniq
    else
      @cuentas = @cuentas.none
    end
    respond_to do |format|
      format.html
      format.ods { render ods: SpreadsheetArchitect::to_ods(Account.depreciacion_activos_ods(@desde, @hasta, @cuentas)), filename: "resumen-de-activos-fijos" }
      format.pdf do
        filename = 'inventario-de-activos-fijos'
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               # show_as_html: params.key?('debug'),
               template: 'reportes/depreciacion.html.haml',
               orientation: 'Landscape',
               page_size: 'Letter',
               margin: view_context.margin_pdf_horizontal_estrecho,
               header: { html: { template: 'shared/header_horizontal.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # Resumen activos fijos - reporte 6 vSIAF
  def resumen
    @desde, @hasta = get_fechas(params)
    if @desde && @hasta
      @accounts = Account.joins(auxiliaries: {assets: :ingreso})
                         .where('ingresos.factura_fecha' => @desde..@hasta)
                         .order(:code)
                         .uniq
    else
      @accounts = Account.none
    end
    respond_to do |format|
      format.html
      format.ods { render ods: SpreadsheetArchitect::to_ods(Account.resumen_activos_ods(@desde, @hasta, @accounts)), filename: "resumen-de-activos-fijos" }
      format.pdf do
        filename = 'resumen-de-activos-fijos'
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               # show_as_html: params.key?('debug'),
               template: 'reportes/resumen.html.haml',
               orientation: 'Landscape',
               page_size: 'Letter',
               margin: view_context.margin_pdf_horizontal_estrecho,
               header: { html: { template: 'shared/header_horizontal.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # Inventario fisico - valorado v2 (Almacenes)
  def inventario_fisico_valorado_v2
    @cuentas = Material.activos.order('code')
  end

  # Estadísticas de materiales por fecha
  def estadisticas
    @desde, @hasta = get_fechas(params)
    @resultados = RawSQL.new('1_resultados.sql').result(desde: @desde, hasta: @hasta)
    respond_to do |format|
      format.html
      format.pdf do
        filename = 'Salida de artículos por unidad'
        render pdf: "#{filename}".parameterize,
               disposition: 'attachment',
               template: 'reportes/estadisticas.html.haml',
               show_as_html: params[:debug].present?,
               orientation: 'Landscape',
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header_horizontal.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # Reporte de bajas de activos fijos - reporte 9 vSIAF
  def bajas
    @desde, @hasta = get_fechas(params)
    cuentas = params[:cuentas]
    @cuentas = Account
    @cuentas = @cuentas.where(id: cuentas) if cuentas.present?
    if @desde && @hasta
      @cuentas = @cuentas.joins(auxiliaries: {assets: :baja})
                         .where(bajas: {fecha: @desde..@hasta})
                         .uniq
    else
      @cuentas = @cuentas.none
    end
    respond_to do |format|
      format.html
      format.ods { render ods: SpreadsheetArchitect::to_ods(Account.bajas_ods(@desde, @hasta, @cuentas)), filename: "reporte-bajas-activos-fijos" }
      format.pdf do
        filename = 'reporte-bajas-activos-fijos'
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               # show_as_html: params.key?('debug'),
               template: 'reportes/bajas.html.haml',
               orientation: 'Landscape',
               page_size: 'Letter',
               margin: view_context.margin_pdf_horizontal_estrecho,
               header: { html: { template: 'shared/header_horizontal.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  private

    def comprimir_a_zip(desde, hasta)
      nombres_archivos = Dir["tmp/*.pdf"]
      archivo_zip = "tmp/kardex_#{desde}_#{hasta}.zip"
      # Eliminación del ZIP
      File.delete archivo_zip if File.exist?(archivo_zip)

      Zip::File.open(archivo_zip, Zip::File::CREATE) do |zipfile|
        nombres_archivos.each do |filename|
          # Two arguments:
          # - The name of the file as it will appear in the archive
          # - The original file, including the path to find it
          nombre = filename.gsub(/tmp/, 'kardex')
          zipfile.add(nombre, filename)
        end
        zipfile.get_output_stream("README.md") { |os| os.write "Kardexes desde #{desde} hasta #{hasta}" }
      end
      archivo_zip
    end
end
