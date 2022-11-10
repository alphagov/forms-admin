# frozen_string_literal: true

module MarkCompleteComponent
  class View < ViewComponent::Base
    def initialize(form:, path:, legend: t("mark_complete.legend"), hint: t("mark_complete.hint"))
      super
      @mark_complete_form = form
      @path = path
      @legend = legend
      @hint = hint
    end

    def render?
      FeatureService.enabled?(:task_list_statuses)
    end
  end
end
