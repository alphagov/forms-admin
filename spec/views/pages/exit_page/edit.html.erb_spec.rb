require "rails_helper"

describe "pages/exit_page/edit.html.erb" do
  let(:form) { build :form, id: 1 }
  let(:group) { build :group }
  let(:pages) do
    build_list(:page, 3)
  end
  let(:condition) { build :condition, :with_exit_page, id: 3, form:, page: pages.first }
  let(:update_exit_page_input) { Pages::UpdateExitPageInput.new(form:, page: pages.first, record: condition).assign_condition_values }

  before do
    render template: "pages/exit_page/edit", locals: { update_exit_page_input:, preview_html: "Preview HTML", check_preview_validation: "true" }
  end

  it "sets the correct title" do
    expect(view.content_for(:title)).to eq "Edit exit page"
  end

  it "contains page heading and sub-heading" do
    expect(rendered).to have_css("h1 .govuk-caption-l", text: "Question #{pages.first.position}’s routes")
    expect(rendered).to have_css("h1.govuk-heading-l", text: "Edit exit page")
  end

  it "has a submit button" do
    expect(rendered).to have_css("button[type='submit'].govuk-button", text: I18n.t("save_and_continue"))
  end
end
