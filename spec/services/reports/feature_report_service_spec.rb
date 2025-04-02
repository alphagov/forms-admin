require "rails_helper"

RSpec.describe Reports::FeatureReportService do
  let(:form_documents_response_json) { JSON.parse(file_fixture("form_documents_response.json").read) }

  before do
    allow(Reports::FormDocumentsService).to receive(:live_form_documents).and_return(form_documents_response_json)
  end

  describe "#report" do
    it "returns the feature report" do
      report = described_class.report
      expect(report).to eq({
        total_live_forms: 3,
        live_forms_with_payment: 1,
        live_forms_with_routing: 1,
        live_forms_with_add_another_answer: 1,
        live_forms_with_csv_submission_enabled: 1,
        live_forms_with_answer_type: {
          "address" => 1,
          "date" => 1,
          "email" => 2,
          "name" => 1,
          "national_insurance_number" => 1,
          "number" => 1,
          "phone_number" => 1,
          "selection" => 2,
          "text" => 3,
        },
        live_steps_with_answer_type: {
          "address" => 1,
          "date" => 1,
          "email" => 2,
          "name" => 1,
          "national_insurance_number" => 1,
          "number" => 1,
          "phone_number" => 1,
          "selection" => 2,
          "text" => 5,
        },
      })
    end
  end
end
