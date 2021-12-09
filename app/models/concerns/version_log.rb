module VersionLog
  extend ActiveSupport::Concern

  module ClassMethods
    def register_log(event)
      data = {
        item_type: self.name,
        item_id: nil,
        item_spanish: I18n.t(self.name.to_s.downcase.singularize, scope: 'activerecord.models'),
        whodunnit: PaperTrail.whodunnit,
        event: I18n.t(event, scope: 'versions')
      }
      PaperTrail::Version.create! self.new.set_merge_metadata(data)
    end
  end

  def register_log(event)
    data = {
      item_type: self.class.name,
      item_id: self.id,
      item_spanish: I18n.t(self.class.name.to_s.downcase.singularize, scope: 'activerecord.models'),
      whodunnit: PaperTrail.whodunnit,
      event: I18n.t(event, scope: 'versions')
    }
    PaperTrail::Version.create! paper_trail.merge_metadata(data)
  end

  def set_merge_metadata(data)
    paper_trail.merge_metadata(data)
  end
end
