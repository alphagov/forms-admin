require "rails_helper"

def generate_form_builder(model)
  GOVUKDesignSystemFormBuilder::FormBuilder.new(:form, model,
                                                ActionView::Base.new(ActionView::LookupContext.new(nil), {}, nil), {})
end

RSpec.describe MarkdownEditorComponent::View, type: :component do
  let(:form_builder) { generate_form_builder(Pages::GuidanceForm.new) }

  let(:local_translations) do
    {}
  end

  let(:markdown_editor) do
    described_class.new(:guidance_markdown,
                        form_builder:,
                        render_preview_path: "#",
                        preview_html: "<p>No markdown added</p>",
                        form_model: Pages::GuidanceForm.new,
                        label: "Add some markdown",
                        hint: "Use Markdown to format your content. Formatting help can be found below.",
                        local_translations:)
  end

  before do
    render_inline(markdown_editor)
  end

  it "renders the textarea" do
    expect(page).to have_css('textarea[data-module="markdown-editor-toolbar"]')
  end

  it "renders the preview html" do
    expect(page).to have_css("p", text: "No markdown added")
  end

  it "renders the label and hint" do
    expect(page).to have_css("label", text: markdown_editor.label)
    expect(page).to have_css("div", text: markdown_editor.hint)
  end

  it "renders the edit markdown link" do
    expect(page).to have_link(I18n.t("markdown_editor.edit_markdown_link"), href: "##{markdown_editor.form_field_id}")
  end

  describe "form_field_id" do
    it "returns the form field id" do
      expect(markdown_editor.form_field_id).to eq markdown_editor.govuk_field_id(markdown_editor.form_model, :guidance_markdown)
    end
  end

  describe "translations" do
    context "when there are no local translations present" do
      it "renders the default translations" do
        expect(markdown_editor.translations).to eq(
          {
            preview_description: I18n.t("markdown_editor.preview.description"),
            preview_heading: I18n.t("markdown_editor.preview.heading"),
            preview_markdown: I18n.t("markdown_editor.preview_markdown"),
            preview_tab_text: I18n.t("markdown_editor.preview_tab_text"),
            update_preview: I18n.t("markdown_editor.update_preview"),
            write_tab_text: I18n.t("markdown_editor.write_tab_text"),
            preview_loading: I18n.t("markdown_editor.preview_loading"),
            preview_error: I18n.t("markdown_editor.preview_error"),
            edit_markdown_link: I18n.t("markdown_editor.edit_markdown_link"),
            preview_area_label: I18n.t("markdown_editor.preview_area_label"),
            toolbar: {
              h2: I18n.t("markdown_editor.toolbar.h2"),
              h3: I18n.t("markdown_editor.toolbar.h3"),
              link: I18n.t("markdown_editor.toolbar.link"),
              bullet_list: I18n.t("markdown_editor.toolbar.bullet_list"),
              numbered_list: I18n.t("markdown_editor.toolbar.numbered_list"),
            },
          },
        )
      end
    end

    context "when there are local translations present" do
      let(:local_translations) do
        {
          preview_description: "local preview description",
          preview_heading: "local preview heading",
          preview_markdown: "local preview markdown",
          preview_tab_text: "local preview tab text",
          update_preview: "local update preview",
          write_tab_text: "local write tab text",
          preview_loading: "local preview laoding",
          preview_error: "local preview error",
          edit_markdown_link: "local edit markdown link",
          preview_area_label: "local preview area label",
          toolbar: {
            h2: "local h2",
            h3: "local h3",
            link: "local link",
            bullet_list: "local bullet_list",
            numbered_list: "local numbered_list",
          },
        }
      end

      it "renders the local translations for the changeable fields, but not for the toolbar buttons" do
        expect(markdown_editor.translations).to eq(
          {
            preview_description: local_translations[:preview_description],
            preview_heading: local_translations[:preview_heading],
            preview_markdown: local_translations[:preview_markdown],
            preview_tab_text: local_translations[:preview_tab_text],
            update_preview: local_translations[:update_preview],
            write_tab_text: local_translations[:write_tab_text],
            preview_loading: local_translations[:preview_loading],
            preview_error: local_translations[:preview_error],
            edit_markdown_link: local_translations[:edit_markdown_link],
            preview_area_label: local_translations[:preview_area_label],
            toolbar: {
              h2: I18n.t("markdown_editor.toolbar.h2"),
              h3: I18n.t("markdown_editor.toolbar.h3"),
              link: I18n.t("markdown_editor.toolbar.link"),
              bullet_list: I18n.t("markdown_editor.toolbar.bullet_list"),
              numbered_list: I18n.t("markdown_editor.toolbar.numbered_list"),
            },
          },
        )
      end
    end
  end
end
