# frozen_string_literal: true

module FormUrlComponent
  class View < ApplicationComponent
    def initialize(runner_link:, heading_text: nil, button_text: nil, heading_level: 2)
      super()
      @runner_link = runner_link
      @heading_text = heading_text
      @button_text = button_text
      @heading_level = heading_level
    end

    def before_render
      super
      @heading_text = t("form_url_component.form_url") if @heading_text.nil?
      @button_text = t("form_url_component.copy_to_clipboard") if @button_text.nil?
    end
  end
end
