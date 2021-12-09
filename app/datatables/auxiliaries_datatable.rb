class AuxiliariesDatatable
  delegate :params, :link_to_if, :type_status, :links_actions, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Auxiliary.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |auxiliary|
      [
        auxiliary.code,
        auxiliary.name,
        link_to_if(auxiliary.account, auxiliary.account_name, auxiliary.account, title: auxiliary.account_code),
        type_status(auxiliary.status),
        links_actions(auxiliary)
      ]
    end
  end

  def array
    @auxiliaries ||= fetch_array
  end

  def fetch_array
    Auxiliary.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Auxiliary.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[auxiliaries.code auxiliaries.name accounts.name status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
