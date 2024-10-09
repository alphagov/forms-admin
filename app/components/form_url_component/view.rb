# frozen_string_literal: true

module FormUrlComponent
  class View < ViewComponent::Base
    def initialize(runner_link:, heading_text: nil, button_text: nil)
      super
      @runner_link = runner_link
      @heading_text = heading_text
      @button_text = button_text
    end

    def before_render
      super
      @heading_text = t("form_url_component.form_url") if @heading_text.nil?
      @button_text = t("form_url_component.copy_to_clipboard") if @button_text.nil?
    end
  end
end
