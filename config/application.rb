require_relative "boot"

require "rails/all"

require "./app/lib/hosting_environment"
require "./app/lib/json_log_formatter"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FormsAdmin
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.exceptions_app = routes

    # All forms should use GOVUKDesignSystemFormBuilder by default
    config.action_view.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

    config.view_component.preview_paths = [Rails.root.join("spec/components")]
    config.view_component.preview_route = "/preview"
    config.view_component.preview_controller = "ComponentPreviewController"
    # Replace with value which will be true in local dev
    config.view_component.show_previews = HostingEnvironment.test_environment?

    ### LOGGING CONFIGURATION ###
    config.log_level = :info

    # Use JSON log formatter for better support in Splunk. To use conventional
    # logging use the Logger::Formatter.new.
    config.log_formatter = JsonLogFormatter.new

    if ENV["RAILS_LOG_TO_STDOUT"].present?
      config.logger = ActiveSupport::Logger.new($stdout)
      config.logger.formatter = config.log_formatter

    end

    # Lograge is used to format the standard HTTP request logging
    config.lograge.enabled = true
    config.lograge.formatter = Lograge::Formatters::Json.new

    # Lograge suppresses the default Rails request logging. Set this to true to
    #  make lograge output it which includes some extra debugging
    # information.
    config.lograge.keep_original_rails_log = false

    config.lograge.custom_options = lambda do |event|
      {}.tap do |h|
        h[:host] = event.payload[:host]
        h[:user_id] = event.payload[:user_id]
        h[:user_email] = event.payload[:user_email]
        h[:user_organisation_slug] = event.payload[:user_organisation_slug]
        h[:user_ip] = event.payload[:user_ip]
        h[:request_id] = event.payload[:request_id]
        h[:user_id] = event.payload[:user_id]
        h[:form_id] = event.payload[:form_id] if event.payload[:form_id]
        h[:exception] = event.payload[:exception] if event.payload[:exception]
      end
    end
  end
end
