require "rails_helper"

describe "forms/archive_welsh/show.html.erb" do
  let(:id) { 2 }
  let(:form) { build(:form, :live, id:) }
  let(:confirm_archive_welsh_input) { Forms::ConfirmArchiveWelshInput.new(form:) }

  before do
    assign(:confirm_archive_welsh_input, confirm_archive_welsh_input)
  end

  context "when there are no errors" do
    before do
      render
    end

    it "has a page title" do
      expect(view.content_for(:title)).to include "Archive the Welsh version of this form"
    end

    it "displays the form" do
      expect(rendered).to have_selector("form[action='#{archive_welsh_update_path(id)}'][method='post']")
      expect(rendered).to have_field("forms_confirm_archive_welsh_input[confirm]")
      expect(rendered).to have_button("Save and continue")
    end
  end

  context "when there are errors" do
    before do
      confirm_archive_welsh_input.errors.add(:confirm, "is required")
      render
    end

    it "displays the error summary" do
      expect(rendered).to have_selector(".govuk-error-summary")
    end

    it "sets the page title with error prefix" do
      expect(view.content_for(:title)).to eq(title_with_error_prefix("Archive the Welsh version of this form", true))
    end
  end
end
