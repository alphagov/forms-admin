# frozen_string_literal: true

module HeaderComponent
  class View < ViewComponent::Base
    def initialize(current_user)
      super
      @current_user = current_user
      @show_profile_link = @current_user&.name.present?
      @user_profile_url = Settings.basic_auth.enabled ? nil : GDS::SSO::Config.oauth_root_url
    end

    def before_render
      @signout_url = Settings.basic_auth.enabled ? nil : gds_sign_out_path
    end
  end
end
