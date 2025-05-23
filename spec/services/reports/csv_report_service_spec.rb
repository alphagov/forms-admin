require "rails_helper"

RSpec.describe Reports::CsvReportService do
  subject(:csv_report_service) do
    described_class.new(records)
  end

  describe "#csv" do
    context "when records is an empty list" do
      let(:records) { [] }

      it "returns an empty string" do
        expect(csv_report_service.csv).to eq ""
      end
    end

    context "when records is a list of form documents" do
      let(:records) { JSON.parse(file_fixture("form_documents_response.json").read) }

      it "returns a CSV of forms" do
        expect(csv_report_service.csv).to eq Reports::FormsCsvReportService.new(records).csv
      end
    end

    context "when records is a list of question page documents" do
      let(:records) { Reports::FeatureReportService.new(form_documents).questions }
      let(:form_documents) { JSON.parse(file_fixture("form_documents_response.json").read) }

      it "returns a CSV of questions" do
        expect(csv_report_service.csv).to eq Reports::QuestionsCsvReportService.new(records).csv
      end
    end
  end
end
