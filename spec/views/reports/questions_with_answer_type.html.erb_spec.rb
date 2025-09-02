require "rails_helper"

describe "reports/questions_with_answer_type" do
  let(:questions) do
    [
      { "data" => { "question_text" => "Email address" }, "form" => { "form_id" => 1, "tag" => tag, "content" => { "name" => "All question types form" }, "group" => { "organisation" => { "name" => "Government Digital Service" } } } },
      { "data" => { "question_text" => "What’s your email address?" }, "form" => { "form_id" => 3, "tag" => tag, "content" => { "name" => "Branch route form" }, "group" => { "organisation" => { "name" => "Government Digital Service" } } } },
    ]
  end
  let(:tag) { "live" }

  let(:answer_type) { "email" }

  before do
    controller.request.path_parameters[:tag] = tag
    controller.request.path_parameters[:answer_type] = answer_type

    render locals: { tag:, answer_type:, questions: }
  end

  describe "page title" do
    it "matches the heading" do
      expect(view.content_for(:title)).to eq "Live questions with email address answer type"
      expect(rendered).to have_css "h1", text: view.content_for(:title)
    end
  end

  it "has a back link to feature usage report" do
    expect(view.content_for(:back_link)).to have_link("Back to feature and answer type usage", href: report_features_path)
  end

  it "has a link to download the CSV" do
    expect(rendered).to have_link("Download all questions in live forms with this answer type as a CSV file", href: report_questions_with_answer_type_path(answer_type: "email", format: :csv))
  end

  describe "questions table" do
    it "has the correct headers" do
      page = Capybara.string(rendered.html)
      expect(page.find_all(".govuk-table__header")[0]).to have_text "Form name"
      expect(page.find_all(".govuk-table__header")[1]).to have_text "Organisation"
      expect(page.find_all(".govuk-table__header")[2]).to have_text "Question text"
    end

    it "has rows for each question" do
      expect(rendered).to have_table with_rows: [
        { "Form name" => "All question types form", "Organisation" => "Government Digital Service", "Question text" => "Email address" },
        { "Form name" => "Branch route form", "Organisation" => "Government Digital Service", "Question text" => "What’s your email address?" },
      ]
    end
  end

  context "when there are no questions to render" do
    let(:questions) { [] }

    it "does not have a link to download a CSV" do
      expect(rendered).not_to have_link(href: url_for(format: :csv))
    end

    it "does not render a table" do
      expect(rendered).not_to have_table
    end

    it "renders the empty message" do
      expect(rendered).to include I18n.t("reports.questions_with_answer_type.empty", tag:, answer_type:)
    end
  end
end
