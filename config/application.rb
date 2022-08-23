require_relative "boot"

require "rails/all"

require "./app/lib/hosting_environment"

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

    config.view_component.preview_paths = [Rails.root.join("spec/components")]
    config.view_component.preview_route = "/preview"
    # Replace with value which will be true in local dev and PAAS dev
    config.view_component.show_previews = HostingEnvironment.test_environment?
  end
end
