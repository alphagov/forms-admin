module ErrorSummaryComponent
  class View < ApplicationComponent
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
