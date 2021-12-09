class MaterialsDatatable
  delegate :params, :link_to, :type_status, :links_actions, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Material.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |material|
      [
        material.code,
        material.description,
        type_status(material.status),
        links_actions(material)
      ]
    end
  end

  def array
    @entities ||= fetch_array
  end

  def fetch_array
    Material.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Material.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[code description status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
