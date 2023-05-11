module ErrorSummaryComponent
  class View < ViewComponent::Base
    attr_accessor :errors

    def initialize(errors: [])
      super
      @errors = errors
    end

    def render?
      @errors.any?
    end
  end
end
