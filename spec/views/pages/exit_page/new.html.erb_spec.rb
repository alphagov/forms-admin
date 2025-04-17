require "rails_helper"

describe "pages/exit_page/new.html.erb" do
  let(:form) { build :form, id: 1 }
  let(:group) { build :group }
  let(:pages) do
    build_list(:page, 3)
  end
  let(:exit_page_input) { Pages::ExitPageInput.new(form:, page: pages.first, answer_value: "Option 1") }

  before do
    render template: "pages/exit_page/new", locals: { exit_page_input: }
  end

  it "sets the correct title" do
    expect(view.content_for(:title)).to eq "Add exit page"
  end

  it "contains page heading and sub-heading" do
    expect(rendered).to have_css("h1 .govuk-caption-l", text: "Question #{pages.first.position}’s routes")
    expect(rendered).to have_css("h1.govuk-heading-l", text: "Add exit page")
  end

  it "has a submit button" do
    expect(rendered).to have_css("button[type='submit'].govuk-button", text: I18n.t("save_and_continue"))
  end
end
