require "rails_helper"

RSpec.describe ReportsController, type: :request do
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
    let(:features_report_service_spy) { instance_double(FeaturesReportService) }
    let(:features_data) do
      {
        features_rows: [
          { key: { text: "Total live forms" }, value: { text: 3 } },
          { key: { text: "Live forms with routes" }, value: { text: 2 } },
          { key: { text: "Live forms with payments" }, value: { text: 1 } },
        ],
        live_forms_with_answer_type: Report.new({
          address: 1,
          date: 1,
          email: 1,
          name: 1,
          national_insurance_number: 1,
          number: 1,
          organisation_name: 1,
          phone_number: 1,
          selection: 3,
          text: 3,
        }),
        live_pages_with_answer_type: Report.new(
          address: 1,
          date: 1,
          email: 1,
          name: 1,
          national_insurance_number: 1,
          number: 1,
          organisation_name: 2,
          phone_number: 1,
          selection: 4,
          text: 5,
        ),
      }
    end

    before do
      allow(FeaturesReportService).to receive(:new).and_return features_report_service_spy
      allow(features_report_service_spy).to receive(:features_data).and_return(features_data)
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
        expect(response.body).to include "Total live forms"
        expect(response.body).to include features_data[:features_rows][0][:value][:text].to_s
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
end
