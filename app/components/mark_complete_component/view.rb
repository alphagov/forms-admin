# frozen_string_literal: true

module MarkCompleteComponent
  class View < ViewComponent::Base
    def initialize(pages, mark_complete_form, path)
      super
      @pages = pages
      @mark_complete_form = mark_complete_form
      @path = path
      @mark_complete_options = [OpenStruct.new(value: "true"), OpenStruct.new(value: "false")]
    end

    def render?
      @pages.any? && FeatureService.enabled?(:task_list_statuses)
    end
  end
end
