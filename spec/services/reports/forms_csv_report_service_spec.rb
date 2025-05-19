require "rails_helper"

RSpec.describe Reports::FormsCsvReportService do
  subject(:csv_reports_service) do
    described_class.new(form_documents)
  end

  let(:form_documents) { JSON.parse(file_fixture("form_documents_response.json").read) }

  let(:group) { create(:group) }

  before do
    GroupForm.create!(form_id: 1, group:)
    GroupForm.create!(form_id: 2, group:)
    GroupForm.create!(form_id: 3, group:)
    GroupForm.create!(form_id: 4, group:)
  end

  describe "#csv" do
    it "returns a CSV with a header row and a row for each form" do
      csv = csv_reports_service.csv
      rows = CSV.parse(csv)
      expect(rows.length).to eq 5
    end

    it "has expected values" do
      csv = csv_reports_service.csv
      rows = CSV.parse(csv)
      expect(rows[1]).to eq([
        "1",
        "live",
        "All question types form",
        "all-question-types-form",
        group.organisation.name,
        group.organisation.id.to_s,
        group.name,
        group.external_id,
        "2025-01-02T16:24:31.203Z",
        "2025-01-02T16:24:31.255Z",
        "9",
        "false",
        "https://www.gov.uk/payments/your-payment-link",
        nil,
        nil,
        "your.email+fakedata84701@gmail.com.gov.uk",
        "08000800",
        "https://www.gov.uk/help/privacy-notice",
        "Test",
        "email_with_csv",
      ])
    end
  end
end
