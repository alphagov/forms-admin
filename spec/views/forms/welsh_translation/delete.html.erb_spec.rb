require "rails_helper"

describe "forms/welsh_translation/delete.html.erb" do
  let(:form) { build(:form, id: 1) }
  let(:delete_welsh_translation_input) { Forms::DeleteWelshTranslationInput.new(form:, confirm:) }
  let(:confirm) { "true" }
  let(:welsh_translation_path) { "/welsh-translation" }

  context "when the form has no errors" do
    before do
      assign(:delete_welsh_translation_input, delete_welsh_translation_input)
      allow(view).to receive(:welsh_translation_path).and_return(welsh_translation_path)
      render
    end

    it "sets the page title" do
      expect(view.content_for(:title)).to eq(t("forms.welsh_translation.delete.title"))
    end

    it "has a back link to the Welsh translation page" do
      expect(view.content_for(:back_link)).to have_link(t("forms.welsh_translation.delete.back_link"), href: welsh_translation_path)
    end

    it "contains page heading and sub-heading" do
      expect(rendered).to have_css(".govuk-caption-l", text: form.name)
      expect(rendered).to have_css("h1", text: t("forms.welsh_translation.delete.title"))
    end

    it "renders radio buttons for confirming deletion" do
      expect(rendered).to have_css("legend", text: t("forms.welsh_translation.delete.title"))
      expect(rendered).to have_field("Yes", type: "radio")
      expect(rendered).to have_field("No", type: "radio")
    end

    it "renders a 'Save and continue' button" do
      expect(rendered).to have_button("Save and continue")
    end
  end

  context "when the form has validation errors" do
    let(:confirm) { nil }

    before do
      delete_welsh_translation_input.validate

      assign(:delete_welsh_translation_input, delete_welsh_translation_input)
      allow(view).to receive(:welsh_translation_path).and_return(welsh_translation_path)
      render
    end

    it "sets the page title with error prefix" do
      expect(view.content_for(:title)).to eq(title_with_error_prefix(t("forms.welsh_translation.delete.title"), true))
    end

    it "has a back link to the Welsh translation page" do
      expect(view.content_for(:back_link)).to have_link(t("forms.welsh_translation.delete.back_link"), href: welsh_translation_path)
    end

    it "displays an error summary box" do
      expect(rendered).to have_css(".govuk-error-summary")
      expect(rendered).to have_css("h2.govuk-error-summary__title", text: "There is a problem")
    end

    it "links the error summary to the invalid field" do
      error_message = I18n.t("activemodel.errors.models.forms/delete_welsh_translation_input.attributes.confirm.blank")
      expect(rendered).to have_link(error_message, href: "#forms-delete-welsh-translation-input-confirm-field-error")
    end

    it "adds an inline error message to the invalid field" do
      error_message = "Error: #{I18n.t('activemodel.errors.models.forms/delete_welsh_translation_input.attributes.confirm.blank')}"
      expect(rendered).to have_css(".govuk-error-message", text: error_message)
    end
  end
end
