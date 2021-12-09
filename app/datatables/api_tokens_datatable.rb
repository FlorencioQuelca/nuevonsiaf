class ApiTokensDatatable
  delegate :params, :type_status,:links_actions, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: ApiToken.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |r|
      [
        r.email,
        r.nombre,
        r.token,
        r.fecha_expiracion.present? ? I18n.l(r.fecha_expiracion) : '',
        type_status(r.status),
        links_actions(r)
      ]
    end
  end

  def array
    @api_tokens ||= fetch_array
  end

  def fetch_array
    ApiToken.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? ApiToken.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[api_tokens.email api_tokens.nombre api_tokens.fecha_expiracion]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
