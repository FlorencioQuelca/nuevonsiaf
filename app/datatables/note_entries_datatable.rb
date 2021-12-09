class NoteEntriesDatatable
  delegate :params, :dom_id, :link_to, :links_actions, :content_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: NoteEntry.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    if Rails.application.secrets.interoperabilidad_plantillas.present?
      array.map do |r|
        [
          I18n.l(r.note_entry_date),
          r.documento_cite,
          r.obtiene_nro_nota_ingreso,
          r.supplier_name,
          r.user_name,
          "#{r.total} #{content_tag(:span, content_tag(:i, '', class: 'fas fa-retweet', 'aria-hidden' => 'true'), class: 'badge badge-warning', title: 'REINGRESO') if r.reingreso?}",
          r.note_date(r.delivery_note_date),
          link_to(content_tag(:span, nil, class: 'glyphicon glyphicon-eye-open'), r, class: 'btn btn-default btn-xs', title: I18n.t('general.btn.show'))
        ]
      end
    else
      array.map do |r|
        [
          I18n.l(r.note_entry_date),
          r.obtiene_nro_nota_ingreso,
          r.supplier_name,
          r.user_name,
          "#{r.total} #{content_tag(:span, content_tag(:i, '', class: 'fas fa-retweet', 'aria-hidden' => 'true'), class: 'badge badge-warning', title: 'REINGRESO') if r.reingreso?}",
          r.note_date(r.delivery_note_date),
          [links_actions(r, 'asset')].join(' ')
        ]
      end
    end
  end

  def array
    @note_entries ||= fetch_array
  end

  def fetch_array
    NoteEntry.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? NoteEntry.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[note_entries.note_entry_date note_entries.nro_nota_ingreso suppliers.name users.name note_entries.total note_entries.delivery_note_date]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
