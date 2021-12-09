class BajasDatatable
  delegate :params, :link_to, :link_to_if, :content_tag, :img_status, :data_link, :links_actions, :current_user, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Baja.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    if Rails.application.secrets.interoperabilidad_plantillas.present?
      array.map do |baja|
        as = []
        as << baja.numero
        as << baja.documento_cite
        as << baja.motivo
        as << baja.documento
        as << (baja.fecha.present? ? I18n.l(baja.fecha) : nil)
        as << links_actions(baja, 'baja')
      end
    else
      array.map do |baja|
        as = []
        as << baja.numero
        as << baja.motivo
        as << baja.documento
        as << (baja.fecha.present? ? I18n.l(baja.fecha) : nil)
        as << links_actions(baja, 'baja')
      end
    end
  end

  def array
    @bajas ||= fetch_array
  end

  def fetch_array
    status = @view.url_for == "#{Rails.application.config.action_controller.relative_url_root}/bajas" ? '1' : '0'
    Baja.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column], status)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Baja.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[bajas.numero bajas.motivo bajas.documento bajas.fecha]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
