# frozen_string_literal: true

module HeaderComponent
  class View < ViewComponent::Base
    def initialize(user_information)
      super
      @user_information = user_information
      @show_profile_link = user_information&.name.present?
      @user_profile_url = GDS::SSO::Config.oauth_root_url
    end
  end
end
