module FormStateTagComponent
  class View < ViewComponent::Base
    attr_accessor :state

    def initialize(state: "DRAFT")
      super
      @state = state.upcase
    end

    def status_colour
      {
        draft: "purple",
        live: "blue",
      }[state.downcase.to_sym]
    end
  end
end
