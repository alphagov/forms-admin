require "rails_helper"

describe "reports/questions_with_add_another_answer" do
  let(:questions) do
    [
      { "type" => "question_page", "data" => { "question_text" => "Email address" }, "form" => { "form_id" => 1, "content" => { "name" => "All question types form" }, "group" => { "organisation" => { "name" => "Government Digital Service" } } } },
      { "type" => "question_page", "data" => { "question_text" => "What’s your email address?" }, "form" => { "form_id" => 3, "content" => { "name" => "Branch route form" }, "group" => { "organisation" => { "name" => "Government Digital Service" } } } },
    ]
  end

  before do
    render locals: { questions: }
  end

  describe "page title" do
    it "matches the heading" do
      expect(view.content_for(:title)).to eq "Questions with add another answer in live forms"
    end
  end

  it "has a back link to feature usage report" do
    expect(view.content_for(:back_link)).to have_link("Back to feature and answer type usage", href: report_features_path)
  end

  it "has a link to download the CSV" do
    expect(rendered).to have_link("Download all questions with add another answer in live forms as a CSV file", href: report_questions_with_add_another_answer_path(format: :csv))
  end

  describe "questions table" do
    it "has the correct headers" do
      page = Capybara.string(rendered.html)
      within(page.find(".govuk-table__head")) do
        expect(page.find_all(".govuk-table__header"[0])).to have_text "Form name"
        expect(page.find_all(".govuk-table__header"[1])).to have_text "Organisation"
        expect(page.find_all(".govuk-table__header"[2])).to have_text "Question text"
      end
    end

    it "has rows for each question" do
      page = Capybara.string(rendered.html)
      within(page.find_all(".govuk-table__row")[1]) do
        expect(page.find_all(".govuk-table__cell"[0])).to have_text "All question types form"
        expect(page.find_all(".govuk-table__cell"[1])).to have_text "Government Digital Service"
        expect(page.find_all(".govuk-table__cell"[2])).to have_text "Email address"
      end
      within(page.find_all(".govuk-table__row")[2]) do
        expect(page.find_all(".govuk-table__cell"[0])).to have_text "Branch route form"
        expect(page.find_all(".govuk-table__cell"[1])).to have_text "Government Digital Service"
        expect(page.find_all(".govuk-table__cell"[2])).to have_text "What's your email address?"
      end
    end
  end
end
