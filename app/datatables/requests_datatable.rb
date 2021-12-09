class RequestsDatatable
  delegate :params, :dom_id, :link_to, :content_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Request.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    if params[:status] != 'initiation' && Rails.application.secrets.interoperabilidad_plantillas.present?
      array.map do |r|
        [
          I18n.l(r.created_at, format: :version),
          r.cite_ems,
          r.obtiene_numero_solicitud,
          r.user_name,
          r.user_title,
          content_tag(:h4, content_tag(:span, I18n.t("requests.title.status.#{r.status}"), class: "label label-#{ r.tipo_estado }")),
          link_to(content_tag(:span, nil, class: 'glyphicon glyphicon-eye-open'), r, class: 'btn btn-default btn-xs', title: I18n.t('general.btn.show'))
        ]
      end
    else
      array.map do |r|
        [
          I18n.l(r.created_at, format: :version),
          r.obtiene_numero_solicitud,
          r.user_name,
          r.user_title,
          content_tag(:h4, content_tag(:span, I18n.t("requests.title.status.#{r.status}"), class: "label label-#{ r.tipo_estado }")),
          link_to(content_tag(:span, nil, class: 'glyphicon glyphicon-eye-open'), r, class: 'btn btn-default btn-xs', title: I18n.t('general.btn.show'))
        ]
      end
    end
  end

  def array
    @requests ||= fetch_array
  end

  def fetch_array
    Request.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column], params[:status])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Request.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[requests.created_at requests.nro_solicitud users.name users.title status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
