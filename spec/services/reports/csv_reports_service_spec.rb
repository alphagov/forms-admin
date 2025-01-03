require "rails_helper"

RSpec.describe Reports::CsvReportsService do
  subject(:csv_reports_service) do
    described_class.new
  end

  let(:form_documents_url) { "#{Settings.forms_api.base_url}/api/v2/form-documents".freeze }
  # This response JSON was generated by making a real API request to forms-api with the data from the database seeds.
  # Once we have transitioned to using the V2 API in forms-admin, it might make more sense to use factories to generate
  # the response.
  let(:form_documents_response_json) { file_fixture("form_documents_response.json").read }

  let(:group) { create(:group) }

  before do
    GroupForm.create!(form_id: 1, group:)
    GroupForm.create!(form_id: 2, group:)
    GroupForm.create!(form_id: 3, group:)

    stub_request(:get, form_documents_url)
      .with(query: { page: "1", per_page: "3", tag: "live" })
      .to_return(body: file_fixture("form_documents_response.json").read, headers: response_headers(9, 0, 3))
    stub_request(:get, form_documents_url)
      .with(query: { page: "2", per_page: "3", tag: "live" })
      .to_return(body: file_fixture("form_documents_response.json").read, headers: response_headers(9, 3, 3))
    stub_request(:get, form_documents_url)
      .with(query: { page: "3", per_page: "3", tag: "live" })
      .to_return(body: file_fixture("form_documents_response.json").read, headers: response_headers(9, 6, 3))
  end

  describe "#live_forms_csv" do
    it "makes request to forms-api for each page of results" do
      csv_reports_service.live_forms_csv
      assert_requested(:get, form_documents_url, query: { page: "1", per_page: "3", tag: "live" }, times: 1)
      assert_requested(:get, form_documents_url, query: { page: "2", per_page: "3", tag: "live" }, times: 1)
      assert_requested(:get, form_documents_url, query: { page: "3", per_page: "3", tag: "live" }, times: 1)
    end

    it "returns a CSV with 10 rows, including the header row" do
      csv = csv_reports_service.live_forms_csv
      rows = CSV.parse(csv)
      expect(rows.length).to eq 10
    end

    it "has expected values" do
      csv = csv_reports_service.live_forms_csv
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
        nil,
        nil,
        nil,
        "your.email+fakedata84701@gmail.com.gov.uk",
        "08000800",
        "https://www.gov.uk/help/privacy-notice",
        "Test",
        "email",
      ])
    end
  end

  def response_headers(total, offset, limit)
    {
      "pagination-total" => total.to_s,
      "pagination-offset" => offset.to_s,
      "pagination-limit" => limit.to_s,
    }
  end
end