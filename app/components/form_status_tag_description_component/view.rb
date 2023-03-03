module FormStatusTagDescriptionComponent
  class View < ViewComponent::Base
    attr_accessor :status

    def initialize(status: :draft)
      super
      @status = status
    end
  end
end
