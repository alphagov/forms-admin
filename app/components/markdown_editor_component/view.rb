# frozen_string_literal: true

module MarkdownEditorComponent
  class View < ViewComponent::Base
    include GOVUKDesignSystemFormBuilder::BuilderHelper
    attr_reader :attribute_name, :f, :render_preview_path, :preview_html, :form_model, :label, :hint

    def initialize(attribute_name,
                   preview_html:,
                   form_model:,
                   form_builder: nil,
                   label: nil,
                   hint: nil,
                   render_preview_path: nil,
                   local_translations: {})
      super
      @attribute_name = attribute_name
      @f = form_builder
      @render_preview_path = render_preview_path
      @preview_html = preview_html
      @form_model = form_model
      @label = label
      @hint = hint
      @local_translations = local_translations
    end

    def form_field_id
      govuk_field_id(form_model, attribute_name)
    end

    def preview_button_translation
      form_model.public_send(attribute_name).blank? ? translations[:preview_markdown] : translations[:update_preview]
    end

    def translations
      {
        preview_description: @local_translations[:preview_description] || I18n.t("markdown_editor.preview.description"),
        preview_heading: @local_translations[:preview_heading] || I18n.t("markdown_editor.preview.heading"),
        preview_markdown: @local_translations[:preview_markdown] || I18n.t("markdown_editor.preview_markdown"),
        preview_tab_text: @local_translations[:preview_tab_text] || I18n.t("markdown_editor.preview_tab_text"),
        update_preview: @local_translations[:update_preview] || I18n.t("markdown_editor.update_preview"),
        write_tab_text: @local_translations[:write_tab_text] || I18n.t("markdown_editor.write_tab_text"),
        preview_loading: @local_translations[:preview_loading] || I18n.t("markdown_editor.preview_loading"),
        preview_error: @local_translations[:preview_error] || I18n.t("markdown_editor.preview_error"),
        edit_markdown_link: @local_translations[:edit_markdown_link] || I18n.t("markdown_editor.edit_markdown_link"),
        preview_area_label: @local_translations[:preview_area_label] || I18n.t("markdown_editor.preview_area_label"),
        toolbar: {
          h2: I18n.t("markdown_editor.toolbar.h2"),
          h3: I18n.t("markdown_editor.toolbar.h3"),
          link: I18n.t("markdown_editor.toolbar.link"),
          bullet_list: I18n.t("markdown_editor.toolbar.bullet_list"),
          numbered_list: I18n.t("markdown_editor.toolbar.numbered_list"),
        },
      }
    end
  end
end
