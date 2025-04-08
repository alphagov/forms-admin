require "rails_helper"

describe "reports/forms_with_routes.html.erb" do
  let(:forms) do
    [
      {
        form_name: "All question types form",
        form_id: 1,
        organisation_name: "Government Digital Service",
        number_of_routes: 1,
      },
      {
        form_name: "Branch route form",
        form_id: 3,
        organisation_name: "Government Digital Service",
        number_of_routes: 2,
      },
    ]
  end

  before do
    render template: "reports/forms_with_routes", locals: { forms: }
  end

  describe "page title" do
    it "matches the heading" do
      expect(view.content_for(:title)).to eq "Live forms with routes"
    end
  end

  it "has a back link to feature usage report" do
    expect(view.content_for(:back_link)).to have_link("Back to feature and answer type usage", href: report_features_path)
  end

  it "has a link to download the CSV" do
    expect(rendered).to have_link("Download data about all live forms with routes as a CSV file", href: report_live_forms_with_routes_csv_path)
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
