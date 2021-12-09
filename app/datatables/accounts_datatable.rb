class AccountsDatatable
  delegate :params, :link_to, :type_status, :links_actions, :content_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Account.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |account|
      [
        account.code,
        account.name,
        account.vida_util,
        type_status(account.status),
        links_actions(account, 'account')
      ]
    end
  end

  def array
    @accounts ||= fetch_array
  end

  def fetch_array
    Account.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Account.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[code name vida_util status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
