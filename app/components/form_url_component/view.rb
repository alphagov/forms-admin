# frozen_string_literal: true

module FormUrlComponent
  class View < ViewComponent::Base
    def initialize(runner_link)
      super
      @runner_link = runner_link
    end
  end
end
