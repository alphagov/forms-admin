require "rails_helper"

describe "forms/make_live/make_your_form_live.html.erb" do
  let(:current_form) { OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1", submission_email: "example@example.gov.uk") }
  let(:make_live_input) { Forms::MakeLiveInput.new(form: current_form) }

  before do
    assign(:make_live_input, make_live_input)

    without_partial_double_verification do
      allow(view).to receive_messages(form_path: "/forms/1", make_live_create_path: "forms/1/make-live")
    end
  end

  context "when there are no errors" do
    before do
      render template: "forms/make_live/make_your_form_live", locals: { current_form: }
    end

    it "has the correct page title" do
      expect(view.content_for(:title)).to eq t("page_titles.make_live")
    end

    it "contains a heading" do
      expect(rendered).to have_css("h1", text: t("page_titles.make_live"))
    end

    it "contains the body text" do
      expect(rendered).to include(t("make_live.new.body_html", submission_email: current_form.submission_email))
    end

    it "renders radio buttons for making the draft changes live" do
      expect(rendered).to have_css("legend", text: I18n.t("helpers.label.forms_make_live_input.confirm"))
      expect(rendered).to have_field("Yes", type: "radio")
      expect(rendered).to have_field("No", type: "radio")
    end

    it "renders a submit button" do
      expect(rendered).to have_css("button", text: I18n.t("save_and_continue"))
    end
  end

  context "when there are errors" do
    before do
      make_live_input.errors.add(:confirm, "An error")

      assign(:make_live_input, make_live_input)
      render template: "forms/make_live/make_your_form_live", locals: { current_form: }
    end

    it "displays the error summary" do
      expect(rendered).to have_selector(".govuk-error-summary")
    end

    it "displays an inline error message" do
      expect(rendered).to have_css(".govuk-error-message")
    end

    it "sets the page title with error prefix" do
      expect(view.content_for(:title)).to eq(title_with_error_prefix(t("page_titles.make_live"), true))
    end
  end
end
