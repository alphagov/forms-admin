require "rails_helper"

describe "forms/share_preview/new.html.erb" do
  let(:form) { build(:form, id: 1) }
  let(:page) { Capybara.string(rendered.html) }

  context "when there are no errors" do
    before do
      assign(:share_preview_input, Forms::SharePreviewInput.new(form:).assign_form_values)
      render(template: "forms/share_preview/new", locals: { form: })
    end

    it "has the correct page title" do
      expect(view.content_for(:title)).to eq(t("page_titles.share_preview"))
    end

    it "has a back link to the create form page" do
      expect(view.content_for(:back_link)).to have_link(t("back_link.form_create"), href: form_path(form.id))
    end

    it "has the correct heading" do
      expect(rendered).to have_css("h1", text: t("page_titles.share_preview"))
    end

    it "has the body text" do
      expect(rendered).to include(I18n.t("share_preview.body_html"))
    end

    it "includes the 'Preview link for this draft form' sub-heading" do
      expect(rendered).to have_css("h2", text: t("share_preview.preview_link_heading"))
    end

    it "includes the link to the draft preview" do
      expect(rendered).to have_text("/preview-draft/#{form.id}/#{form.form_slug}")
    end

    it "has a form that will POST to the correct URL" do
      expect(rendered).to have_css("form[action='#{share_preview_create_path(form.id)}'][method='post']")
    end

    it "includes the expected fieldset legend" do
      expect(rendered).to have_css("legend", text: t("share_preview.radios.legend"))
    end

    it "includes the expected fieldset hint" do
      expect(rendered).to have_css(".govuk-hint", text: t("share_preview.radios.hint"))
    end

    it "has a Save an continue button" do
      expect(rendered).to have_button(t("save_and_continue"))
    end
  end

  context "when there are errors" do
    before do
      share_preview_input = Forms::SharePreviewInput.new(form:).assign_form_values
      share_preview_input.errors.add(:mark_complete, "An error")

      assign(:share_preview_input, share_preview_input)
      render(template: "forms/share_preview/new", locals: { form: })
    end

    it "displays the error summary" do
      expect(rendered).to have_selector(".govuk-error-summary")
    end

    it "displays an inline error message" do
      expect(rendered).to have_css(".govuk-error-message")
    end

    it "sets the page title with error prefix" do
      expect(view.content_for(:title)).to eq(title_with_error_prefix(t("page_titles.share_preview"), true))
    end
  end
end
