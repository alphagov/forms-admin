# frozen_string_literal: true

module HeaderComponent
  class View < ViewComponent::Base
    attr_accessor :is_signed_in, :user_name, :user_profile_link, :signout_link, :list_of_users_path

    def initialize(is_signed_in:, user_name:, user_profile_link:, signout_link:, list_of_users_path:)
      super
      @is_signed_in = is_signed_in
      @user_name = user_name
      @user_profile_link = user_profile_link
      @signout_link = signout_link
      @list_of_users_path = list_of_users_path
    end

    def is_signed_in?
      is_signed_in
    end
  end
end
