# frozen_string_literal: true

module HeaderComponent
  class View < ViewComponent::Base
    def initialize(current_user)
      super
      @current_user = current_user
      @show_profile_link = current_user&.name.present?
      @user_profile_url = GDS::SSO::Config.oauth_root_url
    end
  end
end
