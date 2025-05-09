require "rails_helper"

RSpec.describe ReportHelper, type: :helper do
  describe "#report_forms_table_head" do
    it "returns the column headings for a table of forms" do
      expect(helper.report_forms_table_head).to eq [
        "Form name",
        "Organisation",
      ]
    end
  end

  describe "#report_forms_table_rows" do
    let(:forms) do
      [
        { "form_id" => 1, "content" => { "name" => "All question types form" }, "group" => { "organisation" => { "name" => "Government Digital Service" } } },
        { "form_id" => 3, "content" => { "name" => "Branch route form" }, "group" => { "organisation" => { "name" => "Ministry of Tests" } } },
        { "form_id" => 4, "content" => { "name" => "Skip route form" }, "group" => { "organisation" => { "name" => "Department for Testing" } } },
      ]
    end

    it "returns an array of arrays of strings" do
      expect(helper.report_forms_table_rows(forms))
        .to be_an(Array)
        .and(all(be_an(Array)))
        .and(all(all(be_a(String))))
    end

    it "returns a row for each form" do
      expect(helper.report_forms_table_rows(forms).length)
        .to eq forms.length
    end

    it "has a column in each row for each column heading" do
      expect(helper.report_forms_table_rows(forms).map(&:length))
        .to all eq helper.report_forms_table_head.length
    end

    it "formats a link for each form for the first column of each row" do
      expect(helper.report_forms_table_rows(forms).map(&:first)).to eq [
        "<a class=\"govuk-link\" href=\"/forms/1/live/pages\">All question types form</a>",
        "<a class=\"govuk-link\" href=\"/forms/3/live/pages\">Branch route form</a>",
        "<a class=\"govuk-link\" href=\"/forms/4/live/pages\">Skip route form</a>",
      ]
    end

    it "includes the organisation name for each form for the second column of each row" do
      expect(helper.report_forms_table_rows(forms).map(&:second)).to eq [
        "Government Digital Service",
        "Ministry of Tests",
        "Department for Testing",
      ]
    end
  end

  describe "#report_forms_with_routes_table_head" do
    it "returns the column headings for a table of forms and details of their routes" do
      expect(helper.report_forms_with_routes_table_head).to eq [
        "Form name",
        "Organisation",
        "Number of routes",
      ]
    end
  end

  describe "#report_forms_with_routes_table_rows" do
    let(:forms) do
      [
        { "form_id" => 3, "content" => { "name" => "Branch route form" }, "group" => { "organisation" => { "name" => "Ministry of Tests" } }, "metadata" => { "number_of_routes" => 2 } },
        { "form_id" => 4, "content" => { "name" => "Skip route form" }, "group" => { "organisation" => { "name" => "Department for Testing" } }, "metadata" => { "number_of_routes" => 1 } },
      ]
    end

    it "returns an array of arrays of strings" do
      expect(helper.report_forms_with_routes_table_rows(forms))
        .to be_an(Array)
        .and(all(be_an(Array)))
        .and(all(all(be_a(String))))
    end

    it "returns a row for each form" do
      expect(helper.report_forms_with_routes_table_rows(forms).length)
        .to eq forms.length
    end

    it "has a column in each row for each column heading" do
      expect(helper.report_forms_with_routes_table_rows(forms).map(&:length))
        .to all eq helper.report_forms_with_routes_table_head.length
    end

    it "formats a link for each form for the first column of each row" do
      expect(helper.report_forms_with_routes_table_rows(forms).map(&:first)).to eq [
        "<a class=\"govuk-link\" href=\"/forms/3/live/pages\">Branch route form</a>",
        "<a class=\"govuk-link\" href=\"/forms/4/live/pages\">Skip route form</a>",
      ]
    end

    it "includes the organisation name for each form for the second column of each row" do
      expect(helper.report_forms_with_routes_table_rows(forms).map(&:second)).to eq [
        "Ministry of Tests",
        "Department for Testing",
      ]
    end

    it "includes the number of routes in the form" do
      expect(helper.report_forms_with_routes_table_rows(forms).map(&:third)).to eq %w[
        2
        1
      ]
    end
  end

  describe "#report_questions_table_head" do
    it "returns the column headings for a table of questions" do
      expect(helper.report_questions_table_head).to eq [
        "Form name",
        "Organisation",
        "Question text",
      ]
    end
  end

  describe "#report_questions_table_rows" do
    let(:questions) do
      [
        { "data" => { "question_text" => "Email address" }, "form" => { "form_id" => 1, "content" => { "name" => "All question types form" }, "group" => { "organisation" => { "name" => "Government Digital Service" } } } },
        { "data" => { "question_text" => "What’s your email address?" }, "form" => { "form_id" => 3, "content" => { "name" => "Branch route form" }, "group" => { "organisation" => { "name" => "Ministry of Tests" } } } },
      ]
    end

    it "returns an array of arrays of strings" do
      expect(helper.report_questions_table_rows(questions))
        .to be_an(Array)
        .and(all(be_an(Array)))
        .and(all(all(be_a(String))))
    end

    it "formats a link for each form for the first column of each row" do
      expect(helper.report_questions_table_rows(questions).map(&:first)).to eq [
        "<a class=\"govuk-link\" href=\"/forms/1/live/pages\">All question types form</a>",
        "<a class=\"govuk-link\" href=\"/forms/3/live/pages\">Branch route form</a>",
      ]
    end

    it "includes the organisation name for each form for the second column of each row" do
      expect(helper.report_questions_table_rows(questions).map(&:second)).to eq [
        "Government Digital Service",
        "Ministry of Tests",
      ]
    end

    it "includes the question text for each question for the third column of each row" do
      expect(helper.report_questions_table_rows(questions).map(&:third)).to eq [
        "Email address",
        "What’s your email address?",
      ]
    end
  end
end
