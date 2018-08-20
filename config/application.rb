require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Banp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    I18n.available_locales = [:en, :es] # Available locales (English and Spanish)
    config.i18n.default_locale = :en # English as default language
    config.time_zone = 'Eastern Time (US & Canada)' # GTM-5 (Miami, Florida)

    # Reload local environments variables
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'secrets.yml')

      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end

  end
end
