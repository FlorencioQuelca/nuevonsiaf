class IngresosDatatable
  delegate :params, :dom_id, :link_to, :links_actions, :content_tag, :number_with_delimiter, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Ingreso.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    if Rails.application.secrets.interoperabilidad_plantillas.present?
      array.map do |r|
        [
          r.obtiene_numero,
          r.documento_cite,
          r.factura_fecha.present? ? I18n.l(r.factura_fecha) : '',
          r.factura_numero,
          r.supplier_name,
          r.telefono_proveedor,
          r.user_name,
          number_with_delimiter(r.total),
          r.nota_entrega_fecha.present? ? I18n.l(r.nota_entrega_fecha) : '',
          link_to(content_tag(:span, nil, class: 'glyphicon glyphicon-eye-open'), r, class: 'btn btn-default btn-xs', title: I18n.t('general.btn.show'))
        ]
      end
    else
      array.map do |r|
        [
          r.obtiene_numero,
          r.factura_fecha.present? ? I18n.l(r.factura_fecha) : '',
          r.factura_numero,
          r.supplier_name,
          r.telefono_proveedor,
          r.user_name,
          number_with_delimiter(r.total),
          r.nota_entrega_fecha.present? ? I18n.l(r.nota_entrega_fecha) : '',
          [links_actions(r, 'ingreso')].join(' ')
        ]
      end
    end
  end

  def array
    @ingresos ||= fetch_array
  end

  def fetch_array
    Ingreso.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Ingreso.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[ingresos.numero ingresos.factura_fecha ingresos.factura_numero  ingresos.factura_fecha suppliers.name users.name ingresos.total ingresos.nota_entrega_fecha]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
