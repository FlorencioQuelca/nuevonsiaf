class UbicacionesDatatable
  delegate :params, :link_to, :type_status, :links_actions, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Ubicacion.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |ubicacion|
      [
        ubicacion.abreviacion,
        ubicacion.descripcion,
        links_actions(ubicacion, 'ubicacion')
      ]
    end
  end

  def array
    @entities ||= fetch_array
  end

  def fetch_array
    Ubicacion.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Ubicacion.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[abreviacion descripcion]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
