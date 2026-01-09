require "rails_helper"

RSpec.describe ReportHelper, type: :helper do
  let(:forms) do
    [
      { "form_id" => 1, "tag" => "live", "content" => { "name" => "All question types form" }, "organisation_name" => "Government Digital Service" },
      { "form_id" => 3, "tag" => "live", "content" => { "name" => "Branch route form" }, "organisation_name" => "Ministry of Tests" },
      { "form_id" => 4, "tag" => "live", "content" => { "name" => "Skip route form" }, "organisation_name" => "Department for Testing" },
    ]
  end

  let(:forms_with_routes) do
    [
      { "form_id" => 3, "tag" => "live", "content" => { "name" => "Branch route form" }, "organisation_name" => "Ministry of Tests", "metadata" => { "number_of_routes" => 2, "number_of_branch_routes" => 1 } },
      { "form_id" => 4, "tag" => "live", "content" => { "name" => "Skip route form" }, "organisation_name" => "Department for Testing", "metadata" => { "number_of_routes" => 1, "number_of_branch_routes" => 0 } },
    ]
  end

  let(:questions) do
    [
      { "type" => "question_page", "data" => { "question_text" => "Email address" }, "form" => { "form_id" => 1, "tag" => "live", "content" => { "name" => "All question types form" }, "organisation_name" => "Government Digital Service" } },
      { "type" => "question_page", "data" => { "question_text" => "What’s your email address?" }, "form" => { "form_id" => 3, "tag" => "live", "content" => { "name" => "Branch route form" }, "organisation_name" => "Ministry of Tests" } },
    ]
  end

  describe "#report_table" do
    before do
      allow(helper).to receive(:report_forms_table).and_call_original
      allow(helper).to receive(:report_forms_with_routes_table).and_call_original
      allow(helper).to receive(:report_questions_table).and_call_original
    end

    context "with 'forms' type" do
      it "calls #report_forms_table" do
        helper.report_table(:forms, forms)
        expect(helper).to have_received(:report_forms_table).with(forms)
      end
    end

    context "with 'forms_with_routes' type" do
      it "calls #report_forms_with_routes_table" do
        helper.report_table(:forms_with_routes, forms_with_routes)
        expect(helper).to have_received(:report_forms_with_routes_table).with(forms_with_routes)
      end
    end

    context "with 'questions' type" do
      it "calls #report_questions_table" do
        helper.report_table(:questions, questions)
        expect(helper).to have_received(:report_questions_table).with(questions)
      end
    end
  end

  describe "#report_forms_table" do
    it "has table head" do
      expect(helper.report_forms_table(forms)).to include(
        head: helper.report_forms_table_head,
      )
    end

    it "has table rows" do
      expect(helper.report_forms_table(forms)).to include(
        rows: helper.report_forms_table_rows(forms),
      )
    end
  end

  describe "#report_forms_with_routes_table" do
    it "has table head" do
      expect(helper.report_forms_with_routes_table(forms_with_routes)).to include(
        head: helper.report_forms_with_routes_table_head,
      )
    end

    it "has table rows" do
      expect(helper.report_forms_with_routes_table(forms_with_routes)).to include(
        rows: helper.report_forms_with_routes_table_rows(forms_with_routes),
      )
    end
  end

  describe "#report_questions_table" do
    it "has table head" do
      expect(helper.report_questions_table(questions)).to include(
        head: helper.report_questions_table_head,
      )
    end

    it "has table rows" do
      expect(helper.report_questions_table(questions)).to include(
        rows: helper.report_questions_table_rows(questions),
      )
    end
  end

  describe "#report_forms_table_head" do
    it "returns the column headings for a table of forms" do
      expect(helper.report_forms_table_head).to eq [
        "Form name",
        "Organisation",
      ]
    end
  end

  describe "#report_forms_table_rows" do
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

    context "when the form is live" do
      it "formats a link to the live form pages" do
        form = forms.first.merge("tag" => "live")
        expect(helper.report_forms_table_rows([form]).first.first).to eq(
          "<a class=\"govuk-link\" href=\"/forms/1/live/pages\">All question types form</a>",
        )
      end
    end

    context "when the form is a draft" do
      it "formats a link to the form pages" do
        form = forms.first.merge("tag" => "draft")
        expect(helper.report_forms_table_rows([form]).first.first).to eq(
          "<a class=\"govuk-link\" href=\"/forms/1/pages\">All question types form</a>",
        )
      end
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
        "Number of branch routes",
      ]
    end
  end

  describe "#report_forms_with_routes_table_rows" do
    let(:forms) { forms_with_routes }

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

    it "includes the number of branch routes in the form" do
      expect(helper.report_forms_with_routes_table_rows(forms).map(&:fourth)).to eq %w[
        1
        0
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
