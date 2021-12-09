module Migrated
  extend ActiveSupport::Concern

  included do
    attr_accessor :is_migrate
    after_initialize :init
  end

  def init
    self.is_migrate ||= false
  end

  def is_migrate?
    if respond_to?(:role)
      self.is_migrate == true && role.nil?
    else
      self.is_migrate == true
    end
  end

  def is_not_migrate?
    if respond_to?(:role)
      self.is_migrate == false && role.nil?
    else
      self.is_migrate == false
    end
  end
end
