# frozen_string_literal: true

module TrialRoleWarningComponent
  class View < ViewComponent::Base
    attr_reader :link_url

    def initialize(link_url:)
      super
      @link_url = link_url
    end
  end
end
