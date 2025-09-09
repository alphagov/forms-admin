module FormStatusTagDescriptionComponent
  class View < ApplicationComponent
    attr_accessor :status

    def initialize(status: :draft)
      super()
      @status = status
    end
  end
end
