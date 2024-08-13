require "rails_helper"

describe FeaturesReportService do
  subject(:features_report_service) do
    described_class.new
  end

  let(:report_data) do
    { total_live_forms: 3,
      live_forms_with_answer_type: { address: 1,
                                     date: 1,
                                     email: 1,
                                     name: 1,
                                     national_insurance_number: 1,
                                     number: 1,
                                     organisation_name: 1,
                                     phone_number: 1,
                                     selection: 3,
                                     text: 3 },
      live_pages_with_answer_type: { address: 1,
                                     date: 1,
                                     email: 1,
                                     name: 1,
                                     national_insurance_number: 1,
                                     number: 1,
                                     organisation_name: 2,
                                     phone_number: 1,
                                     selection: 4,
                                     text: 5 },
      live_forms_with_payment: 1,
      live_forms_with_routing: 2 }
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/reports/features", headers, report_data.to_json, 200
    end
  end

  describe "#features_data" do
    it "returns the correct format" do
      expect(features_report_service.features_data).to eq({
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
      })
    end
  end

  context "when one or more of the answer types is not included" do
    let(:report_data) do
      { total_live_forms: 3,
        live_forms_with_answer_type: {},
        live_pages_with_answer_type: {},
        live_forms_with_payment: 1,
        live_forms_with_routing: 2 }
    end

    it "returns 0 for all of the answer types" do
      expect(features_report_service.features_data[:answer_type_table_data][:rows]).to eq(
        [
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.name") },
            { text: 0, numeric: true },
            { text: 0, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.organisation_name") },
            { text: 0, numeric: true },
            { text: 0, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.email") },
            { text: 0, numeric: true },
            { text: 0, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.phone_number") },
            { text: 0, numeric: true },
            { text: 1, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.national_insurance_number") },
            { text: 0, numeric: true },
            { text: 0, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.address") },
            { text: 0, numeric: true },
            { text: 0, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.date") },
            { text: 0, numeric: true },
            { text: 0, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.selection") },
            { text: 0, numeric: true },
            { text: 0, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.number") },
            { text: 0, numeric: true },
            { text: 0, numeric: true },
          ],
          [
            { text: I18n.t("helpers.label.page.answer_type_options.names.text") },
            { text: 3, numeric: true },
            { text: 5, numeric: true },
          ],
        ],
      )
    end
  end
end
