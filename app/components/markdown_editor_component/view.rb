# frozen_string_literal: true

module MarkdownEditorComponent
  class View < ViewComponent::Base
    attr_reader :attribute_name, :f, :render_preview_path, :preview_html, :form_model, :label, :hint, :write_heading, :preview_heading

    def initialize(attribute_name, render_preview_path:, preview_html:, form_model:, form_builder: nil, label: nil, hint: nil, write_heading: "Write", preview_heading: "Preview")
      super
      @attribute_name = attribute_name
      @f = form_builder
      @render_preview_path = render_preview_path
      @preview_html = preview_html
      @form_model = form_model
      @label = label
      @hint = hint
      @write_heading = write_heading
      @preview_heading = preview_heading
    end

    def form_field_id_prefix
      "markdown-editor-#{attribute_name}"
    end
  end
end
