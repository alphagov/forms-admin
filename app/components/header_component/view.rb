# frozen_string_literal: true

module HeaderComponent
  class View < ViewComponent::Base
    def initialize(user_information, profile_path, sign_out_path)
      super
      @user_information = user_information
      @show_profile_link = user_information&.name.present?
      @user_profile_url = profile_path
      @sign_out_path = sign_out_path
    end
  end
end
