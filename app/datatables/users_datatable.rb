class UsersDatatable
  delegate :current_user, :params, :link_to_if, :links_actions, :type_status, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: User.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: current_user.is_super_admin? ? data_admin : data
    }
  end

private

  def data_admin
    array.map do |user|
      [
        user.ci,
        user.name,
        user.role.present? ? I18n.t(user.role, scope: 'users.roles') : '',
        type_status(user.status),
        (links_actions(user) unless user.role == 'super_admin')
      ]
    end
  end

  def data
    array.map do |user|
      as = []
      as << user.ci
      as << user.name
      as << user.title
      as << link_to_if(user.department, user.department_name, user.department, title: user.department_code)
      as << user.assets_count if current_user.is_admin?
      as << type_status(user.status)
      as << links_actions(user)
      as
    end
  end

  def array
    @users ||= fetch_array
  end

  def fetch_array
    User.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column], current_user)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? User.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = current_user.is_super_admin? ? %w[users.name role users.status] : %w[users.code users.ci users.name title departments.name users.assets_count users.status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
