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
      expect(features_report_service.features_data.to_json).to eq({
        features_rows: [
          { key: { text: "Total live forms" }, value: { text: 3 } },
          { key: { text: "Live forms with routes" }, value: { text: 2 } },
          { key: { text: "Live forms with payments" }, value: { text: 1 } },
        ],
        live_forms_with_answer_type: { address: 1, date: 1, email: 1, name: 1, national_insurance_number: 1, number: 1, organisation_name: 1, phone_number: 1, selection: 3, text: 3 },
        live_pages_with_answer_type: { address: 1, date: 1, email: 1, name: 1, national_insurance_number: 1, number: 1, organisation_name: 2, phone_number: 1, selection: 4, text: 5 },
      }.to_json)
    end
  end
end
