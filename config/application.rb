require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Nsiaf
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'La Paz'
    config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :es

    # This allows for setting the root either via config file or via environment variable.
    config.relative_url_root = Rails.application.secrets.rails_relative_url_root

    # Change devise layout: https://github.com/plataformatec/devise/wiki/How-To%3a-Create-custom-layouts
    config.to_prepare do
      Devise::PasswordsController.layout "login"
    end

    config.active_record.raise_in_transactional_callbacks = true
  end
end
