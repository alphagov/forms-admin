class MarkdownEditorComponent::MarkdownEditorComponentPreview < ViewComponent::Preview
  def default
    form_builder = GOVUKDesignSystemFormBuilder::FormBuilder.new(:form, Pages::GuidanceForm.new,
                                                                 ActionView::Base.new(ActionView::LookupContext.new(nil), {}, nil), {})

    render(MarkdownEditorComponent::View.new(:guidance_markdown,
                                             form_builder:,
                                             preview_html: "<p>No markdown added</p>",
                                             form_model: Pages::GuidanceForm.new,
                                             label: "Add some markdown",
                                             hint: "Use Markdown to format your content. Formatting help can be found below."))
  end

  def with_local_translations
    form_builder = GOVUKDesignSystemFormBuilder::FormBuilder.new(:form, Pages::GuidanceForm.new,
                                                                 ActionView::Base.new(ActionView::LookupContext.new(nil), {}, nil), {})
    render(MarkdownEditorComponent::View.new(:guidance_markdown,
                                             form_builder:,
                                             preview_html: "<p>No markdown added</p>",
                                             form_model: Pages::GuidanceForm.new,
                                             label: "Add guidance text",
                                             hint: "Use Markdown if you need to format your guidance content. Formatting help can be found below.",
                                             local_translations: {
                                               preview_description: "Below is a preview of how your guidance content will be shown to the person completing your form.",
                                               preview_heading: "Preview your guidance below",
                                               preview_markdown: "Preview guidance",
                                               preview_tab_text: "Preview guidance",
                                               update_preview: "Update preview",
                                               write_tab_text: "Write guidance",
                                             }))
  end

  def with_headings_disallowed
    form_builder = GOVUKDesignSystemFormBuilder::FormBuilder.new(:form, Pages::GuidanceForm.new,
                                                                 ActionView::Base.new(ActionView::LookupContext.new(nil), {}, nil), {})

    render(MarkdownEditorComponent::View.new(:guidance_markdown,
                                             form_builder:,
                                             preview_html: "<p>No markdown added</p>",
                                             form_model: Pages::GuidanceForm.new,
                                             label: "Add some markdown",
                                             hint: "Use Markdown to format your content. Formatting help can be found below.", allow_headings: false))
  end
end
