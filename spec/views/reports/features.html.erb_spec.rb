require "rails_helper"

describe "reports/features.html.erb" do
  let(:report) do
    {
      features_rows: [
        { key: { text: "Total live forms" }, value: { text: 3 } },
        { key: { text: "Live forms with routes" }, value: { text: 2 } },
        { key: { text: "Live forms with payments" }, value: { text: 1 } },
      ],
      answer_type_table_data: {
        caption: I18n.t("reports.features.answer_types.heading"),
        head: [
          I18n.t("reports.features.answer_types.table_headings.answer_type"),
          { text: I18n.t("reports.features.answer_types.table_headings.number_of_forms"), numeric: true },
          { text: I18n.t("reports.features.answer_types.table_headings.number_of_pages"), numeric: true },
        ],
        rows: [
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.name") },
            { text: 1, numeric: true },
            { text: 1, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.organisation_name") },
            { text: 1, numeric: true },
            { text: 2, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.email") },
            { text: 1, numeric: true },
            { text: 1, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.phone_number") },
            { text: 1, numeric: true },
            { text: 1, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.national_insurance_number") },
            { text: 1, numeric: true },
            { text: 1, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.address") },
            { text: 1, numeric: true },
            { text: 1, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.date") },
            { text: 1, numeric: true },
            { text: 1, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.selection") },
            { text: 3, numeric: true },
            { text: 4, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.number") },
            { text: 1, numeric: true },
            { text: 1, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.text") },
            { text: 3, numeric: true },
            { text: 5, numeric: true },
          ],
        ],
        first_cell_is_header: true,
      },
    }
  end

  before do
    render template: "reports/features", locals: { data: report }
  end

  describe "page title" do
    it "matches the heading" do
      expect(view.content_for(:title)).to eq "Feature usage on live forms"
    end
  end

  it "has a back link to the live form page" do
    expect(view.content_for(:back_link)).to have_link("Back to reports", href: reports_path)
  end

  it "contains page heading" do
    expect(rendered).to have_css("h1.govuk-heading-l", text: "Feature usage on live forms")
  end

  it "includes the number of total live forms" do
    expect(rendered).to have_css(".govuk-summary-list__row", text: "Total live forms#{report[:features_rows][0][:value][:text]}")
  end

  it "contains the answer type table data" do
    report[:answer_type_table_data][:rows].each do |row|
      # contains a heading for the answer type
      expect(rendered).to have_css("th", text: row[0][:text])

      # includes the number of live forms and pages with the answer type
      expect(rendered).to have_table(with_rows: [[row[1][:text].to_s, row[2][:text].to_s]])
    end
  end

  it "includes the number of live forms with routes" do
    expect(rendered).to have_css(".govuk-summary-list__row", text: "Live forms with routes#{report[:features_rows][1][:value][:text]}")
  end

  it "includes the number of live forms with payments" do
    expect(rendered).to have_css(".govuk-summary-list__row", text: "Live forms with payments#{report[:features_rows][2][:value][:text]}")
  end
end
