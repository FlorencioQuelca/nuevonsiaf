class ProceedingsDatatable
  delegate :current_user, :params, :link_to, :link_to_if, :content_tag, :links_actions, :data_link, :type_status, :img_status, :title_status, :dom_id, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Proceeding.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    if Rails.application.secrets.interoperabilidad_plantillas.present?
      array.map do |proceeding|
        [
          proceeding.fecha.present? ? I18n.l(proceeding.fecha, format: :default) : '',
          proceeding.cite_plantillas,
          proceeding.user_name,
          proceeding.admin_name,
          I18n.t(proceeding.get_type, scope: 'proceedings.type'),
          I18n.l(proceeding.created_at, format: :version),
          [link_to(content_tag(:span, "", class: 'glyphicon glyphicon-eye-open'), proceeding, class: 'btn btn-default btn-xs', title: I18n.t('general.btn.show')), link_to(content_tag(:span, "", class: 'glyphicon glyphicon-edit'), '#editar', class: 'btn btn-primary btn-xs editar-acta', title: 'Establecer fecha de asignación/devolución', data: {acta: proceeding.as_json}, id: dom_id(proceeding))].join(' ')
        ]
      end
    else
      array.map do |proceeding|
        [
          proceeding.fecha.present? ? I18n.l(proceeding.fecha, format: :default) : '',
          proceeding.user_name,
          proceeding.admin_name,
          I18n.t(proceeding.get_type, scope: 'proceedings.type'),
          I18n.l(proceeding.created_at, format: :version),
          [link_to(content_tag(:span, "", class: 'glyphicon glyphicon-eye-open'), proceeding, class: 'btn btn-default btn-xs', title: I18n.t('general.btn.show')), link_to(content_tag(:span, "", class: 'glyphicon glyphicon-edit'), '#editar', class: 'btn btn-primary btn-xs editar-acta', title: 'Establecer fecha de asignación/devolución', data: {acta: proceeding.as_json}, id: dom_id(proceeding))].join(' ')
        ]
      end
    end

  end

  def array
    @users ||= fetch_array
  end

  def fetch_array
    Proceeding.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Proceeding.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[fecha users.name admins_proceedings.name proceeding_type created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
