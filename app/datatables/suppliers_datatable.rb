class SuppliersDatatable
  delegate :params, :links_actions, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Supplier.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |r|
      [
        r.id,
        r.name,
        r.nit,
        r.telefono,
        r.contacto,
        links_actions(r, 'asset')
      ]
    end
  end

  def array
    @suppliers ||= fetch_array
  end

  def fetch_array
    Supplier.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Supplier.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[suppliers.id suppliers.name suppliers.created_at suppliers.nit suppliers.telefono suppliers.contacto]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
