# frozen_string_literal: true

module HeaderComponent
  class View < ViewComponent::Base
    attr_accessor :is_signed_in, :user_name, :user_profile_link, :signout_link

    def initialize(is_signed_in:, user_name:, user_profile_link:, signout_link:)
      super
      @is_signed_in = is_signed_in
      @user_name = user_name
      @user_profile_link = user_profile_link
      @signout_link = signout_link
    end

    def is_signed_in?
      is_signed_in
    end
  end
end
