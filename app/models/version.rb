class Version < PaperTrail::Version
  def item_code
    begin
      item.present? && item_type != 'NoteEntry' ? (item.code || item.try(:username)) : ''
    rescue StandardError => e
      ''
    end
  end

  def item_name
    begin
      item.present? && item_type != 'NoteEntry' ? (%w(Material Article Subarticle).include?(item_type) ? item.description : item.name) : ''
    rescue StandardError => e
      ''
    end
  end

  def whodunnit_code
    user = whodunnit_obj
    user.present? ? (user.username || user.name) : ''
  end

  def whodunnit_name
    user = whodunnit_obj
    user.present? ? user.name : ''
  end

  def whodunnit_obj
    User.find_by_id(whodunnit)
  end

  def self.set_columns
   h = ApplicationController.helpers
   column_names.map{ |c| h.get_column(self, c) if %w(event whodunnit item_spanish).include?(c) }.compact
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user)
    array = joins('LEFT OUTER JOIN users ON users.id = versions.whodunnit').order("#{sort_column} #{sort_direction}")
    array = array.where("versions.active = ? AND users.role like ?", true, current_user.role) unless current_user.is_super_admin?
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = search_column == 'whodunnit' ? 'users.username' : "versions.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("versions.item_spanish LIKE ? OR versions.event LIKE ? OR users.username LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    column_names = ['id', 'item_id', 'created_at', 'event', 'whodunnit', 'item_type']
    CSV.generate do |csv|
      csv << column_names.map { |c| Version.human_attribute_name(c) }
      self.all.each do |version|
        a = Array.new
        a << version.id
        a << version.item_code
        a << I18n.l(version.created_at, format: :version)
        a << version.event
        a << version.whodunnit_name
        a << version.item_spanish
        csv << a
      end
    end
  end

  def self.active_false(ids)
    where(id: ids).update_all(active: false)
  end
end
