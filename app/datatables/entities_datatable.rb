class EntitiesDatatable
  delegate :params, :link_to, :content_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Entity.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |entity|
      [
        entity.code,
        entity.name,
        entity.acronym,
        link_to(content_tag(:span, nil, class: 'glyphicon glyphicon-eye-open'), entity, class: 'btn btn-default btn-xs', title: I18n.t('general.btn.show')) + ' ' +
        link_to(content_tag(:span, nil, class: 'glyphicon glyphicon-edit'), [:edit, entity], class: 'btn btn-primary btn-xs', title: I18n.t('general.btn.edit'))
      ]
    end
  end

  def array
    @entities ||= fetch_array
  end

  def fetch_array
    Entity.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Entity.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[code name acronym]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
