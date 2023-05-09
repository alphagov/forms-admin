# frozen_string_literal: true

module MarkCompleteComponent
  class View < ViewComponent::Base
    def initialize(form_model: nil, generate_form: true, form_builder: nil, path: nil, legend: nil, hint: nil)
      super
      if generate_form
        @mark_complete_form = form_model
        @path = path
      else
        @form_builder = form_builder
      end
      @generate_form = generate_form
      @legend = legend
      @hint = hint
    end

    def mark_complete_options
      [OpenStruct.new(value: "true", name: t("mark_complete.true")), OpenStruct.new(value: "false", name: t("mark_complete.false"))]
    end

    def before_render
      super
      @legend = t("mark_complete.legend") if @legend.nil?
      @hint = t("mark_complete.hint") if @hint.nil?
    end
  end
end
