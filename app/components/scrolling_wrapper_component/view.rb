# frozen_string_literal: true

module ScrollingWrapperComponent
  class View < ApplicationComponent
    attr_accessor :aria_label

    def initialize(aria_label:)
      super
      @aria_label = aria_label
    end
  end
end
