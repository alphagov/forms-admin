# frozen_string_literal: true

module TrialRoleWarningComponent
  class View < ViewComponent::Base
    def initialize(current_user)
      super
      @current_user = current_user
    end
  end
end
