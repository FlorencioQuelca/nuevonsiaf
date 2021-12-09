module ManageStatus
  extend ActiveSupport::Concern

  STATUS = {
    '0' => 'inactive',
    '1' => 'active'
  }

  included do
    unless self.const_defined?(:STATUS)
      self.const_set :STATUS, ManageStatus::STATUS
    end
    before_create :set_params
  end

  ##
  # Para utilizar ésta función es necesario tener incluida el módulo VersionLog
  def change_status
    state = self.status == '0' ? '1' : '0'
    if self.update_attribute(:status, state)
      if respond_to?(:register_log)
        register_log(get_status(state))
      else
        logger.info "** Need include module VersionLog in your model"
      end
    end
  end

  def get_status(state)
    status = self.class.const_get(:STATUS)
    status[state]
  end

  def set_params
    self.status = '1'
  end
end
