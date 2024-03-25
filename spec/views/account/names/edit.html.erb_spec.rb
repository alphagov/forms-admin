require "rails_helper"

describe "account/names/edit.html.erb" do
  let(:name_form) { Account::NameForm.new(name: "John Smith") }

  before do
    assign(:name_form, name_form)
  end

  context "when there are no errors" do
    before do
      render
    end

    it "displays the form" do
      expect(rendered).to have_selector('form[action="/account/name"][method="post"]')
      expect(rendered).to have_field("_method", with: "patch", type: :hidden)
      expect(rendered).to have_field("account_name_form[name]", with: "John Smith")
      expect(rendered).to have_button(I18n.t("save_and_continue"))
    end

    it "sets the page title" do
      expect(view.content_for(:title)).to eq(t("page_titles.account_name"))
    end
  end

  context "when there are errors" do
    before do
      name_form.errors.add(:name, "is required")
      render
    end

    it "displays the error summary" do
      expect(rendered).to have_selector(".govuk-error-summary")
    end

    it "sets the page title with error prefix" do
      expect(view.content_for(:title)).to eq(title_with_error_prefix(t("page_titles.account_name"), true))
    end
  end
end
