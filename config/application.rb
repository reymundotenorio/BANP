require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you"ve limited to :test, :development, or :production.
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
    config.time_zone = "Eastern Time (US & Canada)" # GTM-5 (Miami, Florida)
    config.active_record.default_timezone = :local # Or :utc

    # Paperclip S3
    config.paperclip_defaults = {
      storage: :s3,
      s3_credentials: {
        bucket: ENV["s3_bucket_name"],
        access_key_id: ENV["aws_access_key_id"],
        secret_access_key: ENV["aws_secret_access_key"],
        s3_region: ENV["s3_region"],
        s3_host_name: ENV["s3_host_name"]
      }
    }

    # Custom fonts
    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    # Custom errors
    config.exceptions_app = self.routes
  end
end
