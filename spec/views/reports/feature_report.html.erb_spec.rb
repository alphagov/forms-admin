require "rails_helper"

describe "reports/feature_report" do
  let(:report) {}
  let(:records) { [] }

  before do
    controller.request.path_parameters[:report] = report.dasherize

    render locals: { tag:, report:, records: }
  end

  context "with forms_with_csv_submission_enabled report" do
    let(:report) { "forms_with_csv_submission_enabled" }
    let(:records) do
      [
        { "form_id" => 1, "content" => { "name" => "All question types form" }, "group" => { "organisation" => { "name" => "Government Digital Service" } } },
        { "form_id" => 3, "content" => { "name" => "Branch route form" }, "group" => { "organisation" => { "name" => "Government Digital Service" } } },
      ]
    end

    describe "page title" do
      it "matches the heading" do
        expect(view.content_for(:title)).to eq "Live forms with CSV submission enabled"
        expect(rendered).to have_css "h1", text: view.content_for(:title)
      end
    end

    it "has a back link to feature usage report" do
      expect(view.content_for(:back_link)).to have_link("Back to feature and answer type usage", href: report_features_path)
    end

    it "has a link to download the CSV" do
      expect(rendered).to have_link("Download data about all live forms with CSV submission enabled as a CSV file", href: feature_report_path(report: "forms-with-csv-submission-enabled", format: :csv))
    end

    describe "questions table" do
      it "has the correct headers" do
        page = Capybara.string(rendered.html)
        within(page.find(".govuk-table__head")) do
          expect(page.find_all(".govuk-table__header"[0])).to have_text "Form name"
          expect(page.find_all(".govuk-table__header"[1])).to have_text "Organisation"
        end
      end

      it "has rows for each question" do
        page = Capybara.string(rendered.html)
        within(page.find_all(".govuk-table__row")[1]) do
          expect(page.find_all(".govuk-table__cell"[0])).to have_text "All question types form"
          expect(page.find_all(".govuk-table__cell"[1])).to have_text "Government Digital Service"
        end
        within(page.find_all(".govuk-table__row")[2]) do
          expect(page.find_all(".govuk-table__cell"[0])).to have_text "Branch route form"
          expect(page.find_all(".govuk-table__cell"[1])).to have_text "Government Digital Service"
        end
      end
    end
  end

  context "with forms_with_payments report" do
    let(:report) { "forms_with_payments" }
    let(:records) do
      [
        { "form_id" => 1, "content" => { "name" => "All question types form" }, "group" => { "organisation" => { "name" => "Government Digital Service" } } },
        { "form_id" => 3, "content" => { "name" => "Branch route form" }, "group" => { "organisation" => { "name" => "Government Digital Service" } } },
      ]
    end

    describe "page title" do
      it "matches the heading" do
        expect(view.content_for(:title)).to eq "Live forms with payments"
        expect(rendered).to have_css "h1", text: view.content_for(:title)
      end
    end

    it "has a back link to feature usage report" do
      expect(view.content_for(:back_link)).to have_link("Back to feature and answer type usage", href: report_features_path)
    end

    it "has a link to download the CSV" do
      expect(rendered).to have_link("Download data about all live forms with payments as a CSV file", href: feature_report_path(report: "forms-with-payments", format: :csv))
    end

    describe "questions table" do
      it "has the correct headers" do
        page = Capybara.string(rendered.html)
        within(page.find(".govuk-table__head")) do
          expect(page.find_all(".govuk-table__header"[0])).to have_text "Form name"
          expect(page.find_all(".govuk-table__header"[1])).to have_text "Organisation"
        end
      end

      it "has rows for each question" do
        page = Capybara.string(rendered.html)
        within(page.find_all(".govuk-table__row")[1]) do
          expect(page.find_all(".govuk-table__cell"[0])).to have_text "All question types form"
          expect(page.find_all(".govuk-table__cell"[1])).to have_text "Government Digital Service"
        end
        within(page.find_all(".govuk-table__row")[2]) do
          expect(page.find_all(".govuk-table__cell"[0])).to have_text "Branch route form"
          expect(page.find_all(".govuk-table__cell"[1])).to have_text "Government Digital Service"
        end
      end
    end
  end

  context "with forms_with_routes report" do
    let(:report) { "forms_with_routes" }
    let(:records) do
      [
        { "form_id" => 1, "content" => { "name" => "All question types form" }, "group" => { "organisation" => { "name" => "Government Digital Service" } }, "metadata" => { "number_of_routes" => 1 } },
        { "form_id" => 3, "content" => { "name" => "Branch route form" }, "group" => { "organisation" => { "name" => "Government Digital Service" } }, "metadata" => { "number_of_routes" => 2 } },
      ]
    end

    describe "page title" do
      it "matches the heading" do
        expect(view.content_for(:title)).to eq "Live forms with routes"
        expect(rendered).to have_css "h1", text: view.content_for(:title)
      end
    end

    it "has a back link to feature usage report" do
      expect(view.content_for(:back_link)).to have_link("Back to feature and answer type usage", href: report_features_path)
    end

    it "has a link to download the CSV" do
      expect(rendered).to have_link("Download data about all live forms with routes as a CSV file", href: feature_report_path(report: "forms-with-routes", format: :csv))
    end

    describe "questions table" do
      it "has the correct headers" do
        page = Capybara.string(rendered.html)
        within(page.find(".govuk-table__head")) do
          expect(page.find_all(".govuk-table__header"[0])).to have_text "Form name"
          expect(page.find_all(".govuk-table__header"[1])).to have_text "Organisation"
          expect(page.find_all(".govuk-table__header"[2])).to have_text "Number of routes"
        end
      end

      it "has rows for each question" do
        page = Capybara.string(rendered.html)
        within(page.find_all(".govuk-table__row")[1]) do
          expect(page.find_all(".govuk-table__cell"[0])).to have_text "All question types form"
          expect(page.find_all(".govuk-table__cell"[1])).to have_text "Government Digital Service"
          expect(page.find_all(".govuk-table__cell"[2])).to have_text "1"
        end
        within(page.find_all(".govuk-table__row")[2]) do
          expect(page.find_all(".govuk-table__cell"[0])).to have_text "Branch route form"
          expect(page.find_all(".govuk-table__cell"[1])).to have_text "Government Digital Service"
          expect(page.find_all(".govuk-table__cell"[2])).to have_text "2"
        end
      end
    end
  end

  context "with questions_with_add_another_answer report" do
    let(:report) { "questions_with_add_another_answer" }
    let(:records) do
      [
        { "type" => "question_page", "data" => { "question_text" => "email address" }, "form" => { "form_id" => 1, "content" => { "name" => "all question types form" }, "group" => { "organisation" => { "name" => "government digital service" } } } },
        { "type" => "question_page", "data" => { "question_text" => "what’s your email address?" }, "form" => { "form_id" => 3, "content" => { "name" => "branch route form" }, "group" => { "organisation" => { "name" => "government digital service" } } } },
      ]
    end

    describe "page title" do
      it "matches the heading" do
        expect(view.content_for(:title)).to eq "Questions with add another answer in live forms"
        expect(rendered).to have_css "h1", text: view.content_for(:title)
      end
    end

    it "has a back link to feature usage report" do
      expect(view.content_for(:back_link)).to have_link("Back to feature and answer type usage", href: report_features_path)
    end

    it "has a link to download the CSV" do
      expect(rendered).to have_link("Download all questions with add another answer in live forms as a CSV file", href: feature_report_path(report: "questions-with-add-another-answer", format: :csv))
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
end
