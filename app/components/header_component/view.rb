# frozen_string_literal: true

module HeaderComponent
  class View < ViewComponent::Base
    attr_accessor :hosting_environment, :navigation_items

    def initialize(hosting_environment: HostingEnvironment, navigation_items: [])
      super
      @hosting_environment = hosting_environment
      @navigation_items = navigation_items
    end

    def environment_name
      hosting_environment.friendly_environment_name
    end

    def app_header_class_for_environment
      "app-header--#{colour_for_environment}"
    end

    def colour_for_environment
      case environment_name
      when "Local"
        "pink"
      when "Development"
        "green"
      when "Staging"
        "yellow"
      else
        "blue"
      end
    end

    def environment_tag
      # Don't render a tag if this is the production environment
      return { body: nil } if environment_name == "production"

      GovukComponent::TagComponent.new(text: environment_name, colour: colour_for_environment)
    end
  end
end
