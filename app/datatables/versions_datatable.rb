class VersionsDatatable
  delegate :params, :link_to_if, :content_tag, :current_user, :add_check_box, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Version.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |version|
      [
        version.id,
        content_tag(:span, version.item_code, title: version.item_name),
        I18n.l(version.created_at, format: :version),
        version.event,
        link_admin(version),
        version.item_spanish,
        add_check_box(version.id)
      ]
    end
  end

  def array
    @accounts ||= fetch_array
  end

  def fetch_array
    Version.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column], current_user)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Version.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[id item_id created_at event whodunnit item_spanish]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  def link_admin(version)
    if version.whodunnit_obj.present? && !version.whodunnit_obj.is_super_admin?
      link_to_if(version.whodunnit_obj, version.whodunnit_code, version.whodunnit_obj, title: version.whodunnit_name)
    else
      version.whodunnit_code
    end
  end
end
