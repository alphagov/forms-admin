require "rails_helper"

describe "account/terms_of_use/edit.html.erb" do
  let(:terms_of_use_input) { Account::TermsOfUseInput.new }

  before do
    assign(:terms_of_use_input, terms_of_use_input)
  end

  context "when there are no errors" do
    before do
      render
    end

    it "sets the page title" do
      expect(view.content_for(:title)).to eq(t("page_titles.account_terms_of_use"))
    end

    it "displays the form" do
      expect(rendered).to have_selector('form[action="/account/terms_of_use"][method="post"]')
      expect(rendered).to have_field("_method", with: "patch", type: :hidden)

      within "form" do
        expect(rendered).to have_selector("govuk_check_boxes_fieldset")
        expect(rendered).to have_selector("govuk_check_box")
      end

      expect(rendered).to have_button(I18n.t("save_and_continue"))
    end
  end

  context "when there are errors" do
    before do
      terms_of_use_input.errors.add(:base, "Some error")
      render
    end

    it "displays the error summary" do
      expect(rendered).to have_selector(".govuk-error-summary")
    end

    it "sets the page title with error prefix" do
      expect(view.content_for(:title)).to eq(title_with_error_prefix(t("page_titles.account_terms_of_use"), true))
    end
  end
end
