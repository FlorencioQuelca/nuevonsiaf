class SegurosDatatable
  delegate :params, :dom_id, :link_to, :links_actions, :content_tag, :number_with_delimiter, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Seguro.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |r|
      [
        r.tipo,
        r.numero_poliza,
        r.numero_contrato,
        r.proveedor_nombre,
        r.fecha_inicio_vigencia.present? ? I18n.l(r.fecha_inicio_vigencia, format: :long) : '',
        r.fecha_fin_vigencia.present? ? I18n.l(r.fecha_fin_vigencia, format: :long) : '',
        content_tag(:h4, content_tag(:span, r.estado, class: "label label-#{ r.cotizado? ? "warning" : r.vigente? ? "success" : "default" }")),
        r.cantidad_activos,
        [links_actions(r, 'seguro')].join(' ')
      ]
    end
  end

  def array
    @seguros ||= fetch_array
  end

  def fetch_array
    Seguro.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Seguro.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[tipo fecha_inicio_vigencia fecha_fin_vigencia numero_poliza numero_contrato name factura_numero]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
