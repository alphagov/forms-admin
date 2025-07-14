require "rails_helper"

describe "reports/add_another_answer.html.erb" do
  let(:form_id) { 3 }
  let(:name) { "Form name" }
  let(:question_text) { "Question text" }
  let(:state) { "live_with_draft" }
  let(:report) do
    OpenStruct.new(
      count: 1,
      forms: [OpenStruct.new(form_id:, name:, state:, repeatable_pages: [OpenStruct.new(page_id: 5, question_text:)])],
    )
  end

  before do
    render template: "reports/add_another_answer", locals: { data: report }
  end

  describe "page title" do
    it "matches the heading" do
      expect(view.content_for(:title)).to eq "All forms with add another answer"
    end
  end

  it "has a back link to the reports page" do
    expect(view.content_for(:back_link)).to have_link("Back to reports", href: reports_path)
  end

  it "contains a scrollable wrapper with a table in it" do
    expect(rendered).to have_css(".app-scrolling-wrapper > table")
  end

  it "includes the form name" do
    expect(rendered).to have_link(name, href: form_url(form_id))
  end

  it "includes the question text" do
    expect(rendered).to have_content(question_text)
  end

  it "includes the form state with transformations" do
    expect(rendered).to have_content(state.capitalize.gsub("_", " "))
  end
end
