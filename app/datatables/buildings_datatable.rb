class BuildingsDatatable
  delegate :params, :content_tag, :type_status, :links_actions, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Building.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |building|
      [
        building.code,
        building.name,
        content_tag(:span, building.entity_name, title: building.entity_code),
        type_status(building.status),
        links_actions(building)
      ]
    end
  end

  def array
    @buildings ||= fetch_array
  end

  def fetch_array
    Building.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Building.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[buildings.code buildings.name entities.name status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
