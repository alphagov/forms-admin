# frozen_string_literal: true

module ActAsUserBannerComponent
  class View < ViewComponent::Base
    def initialize(acting_as_user, original_user)
      super
      @acting_as_user = acting_as_user
      @original_user = original_user
    end

    def render?
      @original_user.present? && @acting_as_user.present?
    end

    def acting_as_banner_content
      "#{acting_as_content} - #{acting_user_details_content}."
    end

    def acting_as_content
      "You are acting as #{@acting_as_user.name || "user #{@acting_as_user.id}"}"
    end

    def acting_user_details_content
      organisation_text = @acting_as_user.organisation.present? ? "from #{@acting_as_user.organisation.name}" : "with no organisation set"

      user_text = if @acting_as_user.organisation_admin?
                    "an organisation admin"
                  elsif @acting_as_user.standard?
                    "a standard user"
                  else
                    "a user with role: #{@acting_as_user.role}"
                  end

      "#{user_text} #{organisation_text}"
    end

    def stop_acting_as_link_content
      "Stop acting as #{@acting_as_user.name || "user #{@acting_as_user.id}"}"
    end
  end
end
