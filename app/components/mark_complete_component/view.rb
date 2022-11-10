# frozen_string_literal: true

module MarkCompleteComponent
  class View < ViewComponent::Base
    def initialize(form_model: nil, generate_form: true, form_builder: nil, path: nil, legend: t("mark_complete.legend"), hint: t("mark_complete.hint"))
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

    def render?
      FeatureService.enabled?(:task_list_statuses)
    end

    def mark_complete_options
      [OpenStruct.new(value: "true", name: t("mark_complete.true")), OpenStruct.new(value: "false", name: t("mark_complete.false"))]
    end
  end
end
