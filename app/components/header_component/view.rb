# frozen_string_literal: true

module HeaderComponent
  class View < ViewComponent::Base
    attr_accessor :is_signed_in, :user_name, :user_profile_link, :signout_link, :list_of_users_path, :hosting_environment

    def initialize(is_signed_in:, user_name:, user_profile_link:, signout_link:, list_of_users_path:, hosting_environment: HostingEnvironment)
      super
      @is_signed_in = is_signed_in
      @user_name = user_name
      @user_profile_link = user_profile_link
      @signout_link = signout_link
      @list_of_users_path = list_of_users_path
      @hosting_environment = hosting_environment
    end

    def is_signed_in?
      is_signed_in
    end

    def environment_name
      hosting_environment.friendly_environment_name
    end

    def app_header_class_for_environment
      "app-header--#{colour_for_environment}"
    end

    def colour_for_environment
      case environment_name
      when "local"
        "pink"
      when "development"
        "green"
      when "staging"
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
