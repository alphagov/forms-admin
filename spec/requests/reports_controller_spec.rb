require "rails_helper"

RSpec.describe ReportsController, type: :request do
  let(:question_text) { "Question text" }
  let(:report_data) do
    { total_live_forms: 3,
      all_forms_with_add_another_answer: [{ form_id: 3, name: "form name", state: "Draft", repeatable_pages: [{ page_id: 5, question_text: }] }] }
  end

  describe "#index" do
    context "when the user is an editor" do
      before do
        login_as_standard_user

        get reports_path
      end

      it "returns http code 403" do
        expect(response).to have_http_status(:forbidden)
      end

      it "renders the forbidden view" do
        expect(response).to render_template("errors/forbidden")
      end
    end

    context "when the user is an organisation admin" do
      before do
        login_as_organisation_admin_user

        get reports_path
      end

      it "returns http code 403" do
        expect(response).to have_http_status(:forbidden)
      end

      it "renders the forbidden view" do
        expect(response).to render_template("errors/forbidden")
      end
    end

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get reports_path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the features index view" do
        expect(response).to render_template("reports/index")
      end

      it "includes the heading text" do
        expect(response.body).to include "Reports"
      end
    end
  end

  describe "#features" do
    let(:form_documents_url) { "#{Settings.forms_api.base_url}/api/v2/form-documents".freeze }
    let(:form_documents_response_json) { file_fixture("form_documents_response.json").read }
    let(:response_headers) do
      {
        "pagination-total" => "3",
        "pagination-offset" => "0",
        "pagination-limit" => "3",
      }
    end

    before do
      stub_request(:get, form_documents_url)
        .with(query: { page: "1", per_page: "3", tag: "live" })
        .to_return(body: form_documents_response_json, headers: response_headers)
    end

    context "when the user is an editor" do
      before do
        login_as_standard_user

        get report_features_path
      end

      it "returns http code 403" do
        expect(response).to have_http_status(:forbidden)
      end

      it "renders the forbidden view" do
        expect(response).to render_template("errors/forbidden")
      end
    end

    context "when the user is an organisation admin" do
      before do
        login_as_organisation_admin_user

        get report_features_path
      end

      it "returns http code 403" do
        expect(response).to have_http_status(:forbidden)
      end

      it "renders the forbidden view" do
        expect(response).to render_template("errors/forbidden")
      end
    end

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get report_features_path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the features report view" do
        expect(response).to render_template("reports/features")
      end

      it "includes the report data" do
        page = Capybara.string(response.body)
        within(page.find_all(".govuk-summary-list").first) do
          expect(page.find_all(".govuk-summary-list__key")[0]).to have_text "Total live forms"
          expect(page.find_all(".govuk-summary-list__value")[0]).to have_text "3"
        end
      end
    end
  end

  describe "#users" do
    context "when the user is an editor" do
      before do
        login_as_standard_user

        get report_users_path
      end

      it "returns http code 403" do
        expect(response).to have_http_status(:forbidden)
      end

      it "renders the forbidden view" do
        expect(response).to render_template("errors/forbidden")
      end
    end

    context "when the user is an organisation admin" do
      before do
        login_as_organisation_admin_user

        get report_users_path
      end

      it "returns http code 403" do
        expect(response).to have_http_status(:forbidden)
      end

      it "renders the forbidden view" do
        expect(response).to render_template("errors/forbidden")
      end
    end

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get report_users_path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the users report view" do
        expect(response).to render_template("reports/users")
      end
    end
  end

  describe "#add_another_answer" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/reports/features", headers, report_data.to_json, 200
      end
    end

    context "when the user is an editor" do
      before do
        login_as_standard_user

        get report_add_another_answer_path
      end

      it "returns http code 403" do
        expect(response).to have_http_status(:forbidden)
      end

      it "renders the forbidden view" do
        expect(response).to render_template("errors/forbidden")
      end
    end

    context "when the user is an organisation admin" do
      before do
        login_as_organisation_admin_user

        get report_add_another_answer_path
      end

      it "returns http code 403" do
        expect(response).to have_http_status(:forbidden)
      end

      it "renders the forbidden view" do
        expect(response).to render_template("errors/forbidden")
      end
    end

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get report_add_another_answer_path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the features report view" do
        expect(response).to render_template("reports/add_another_answer")
      end

      it "includes the report data" do
        expect(response.body).to include "All forms with add another answer"
        expect(response.body).to include question_text
      end
    end
  end

  describe "#last_signed_in_at" do
    let!(:users) do
      [
        create(:user, provider: :auth0, last_signed_in_at: (1.year + 2.months).ago),
        create(:user, provider: :auth0, last_signed_in_at: nil),
        create(:user, provider: :gds, last_signed_in_at: nil),
      ]
    end

    before do
      login_as_super_admin_user

      get report_last_signed_in_at_path
    end

    it "returns http code 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the last_signed_in_at report view" do
      expect(response).to render_template("reports/last_signed_in_at")
    end

    it "includes the report data" do
      expect(response.body).to include "When users last signed in"
      expect(response.body).to include users.first.email
      expect(response.body).to include users.second.email
      expect(response.body).to include users.third.email
    end
  end

  describe "#selection_questions_summary" do
    let(:summary) do
      {
        autocomplete: {
          form_count: 234,
          question_count: 432,
          optional_question_count: 20,
        },
        radios: {
          form_count: 2,
          question_count: 2,
          optional_question_count: 1,
        },
        checkboxes: {
          form_count: 1,
          question_count: 1,
          optional_question_count: 1,
        },
      }
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/reports/selection-questions-summary", headers, summary.to_json, 200
      end

      login_as_super_admin_user
      get report_selection_questions_summary_path
    end

    it "returns http code 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the selection questions summary report view" do
      expect(response).to render_template("reports/selection_questions/summary")
    end
  end

  describe "selection question reports" do
    let(:data) do
      {
        questions: [
          {
            form_id: 1,
            form_name: "A form",
            question_text: "A question",
            is_optional: true,
            selection_options_count: 33,
          },
        ],
        count: 1,
      }
    end

    describe "#selection_questions_with_autocomplete" do
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/reports/selection-questions-with-autocomplete", headers, data.to_json, 200
        end

        login_as_super_admin_user
        get report_selection_questions_with_autocomplete_path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the autocomplete questions report view" do
        expect(response).to render_template("reports/selection_questions/autocomplete")
      end

      it "includes the report data" do
        expect(response.body).to include "A form"
        expect(response.body).to include "A question"
      end
    end

    describe "#selection_questions_with_radios" do
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/reports/selection-questions-with-radios", headers, data.to_json, 200
        end

        login_as_super_admin_user
        get report_selection_questions_with_radios_path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the autocomplete questions report view" do
        expect(response).to render_template("reports/selection_questions/radios")
      end

      it "includes the report data" do
        expect(response.body).to include "A form"
        expect(response.body).to include "A question"
      end
    end

    describe "#selection_questions_with_checkboxes" do
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/reports/selection-questions-with-checkboxes", headers, data.to_json, 200
        end

        login_as_super_admin_user
        get report_selection_questions_with_checkboxes_path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the autocomplete questions report view" do
        expect(response).to render_template("reports/selection_questions/checkboxes")
      end

      it "includes the report data" do
        expect(response.body).to include "A form"
        expect(response.body).to include "A question"
      end
    end

    describe "#live_forms_csv" do
      let(:csv_reports_service_mock) { instance_double(Reports::CsvReportsService) }
      let(:dummy_csv) { '"Column 1", "Column 2"\n"Value 1", "Value 2"' }

      before do
        allow(Reports::CsvReportsService).to receive(:new).and_return(csv_reports_service_mock)
        allow(csv_reports_service_mock).to receive(:live_forms_csv).and_return(dummy_csv)

        login_as_super_admin_user
        get report_live_forms_csv_path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "responds with an attachment content-disposition header" do
        expect(response.headers["content-disposition"]).to match(/attachment; filename=live_forms_report-.*?\.csv/)
      end

      it "has content-type text/csv" do
        expect(response.headers["content-type"]).to eq "text/csv; charset=iso-8859-1"
      end

      it "has expected response body" do
        expect(response.body).to eq(dummy_csv)
      end
    end

    describe "#live_questions_csv" do
      let(:csv_reports_service_mock) { instance_double(Reports::CsvReportsService) }
      let(:dummy_csv) { '"Column 1", "Column 2"\n"Value 1", "Value 2"' }

      before do
        allow(Reports::CsvReportsService).to receive(:new).and_return(csv_reports_service_mock)
        allow(csv_reports_service_mock).to receive(:live_questions_csv).and_return(dummy_csv)

        login_as_super_admin_user
        get report_live_questions_csv_path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "responds with an attachment content-disposition header" do
        expect(response.headers["content-disposition"]).to match(/attachment; filename=live_questions_report-.*?\.csv/)
      end

      it "has content-type text/csv" do
        expect(response.headers["content-type"]).to eq "text/csv; charset=iso-8859-1"
      end

      it "has expected response body" do
        expect(response.body).to eq(dummy_csv)
      end
    end
  end
end
