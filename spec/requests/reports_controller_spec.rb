require "rails_helper"

RSpec.describe ReportsController, type: :request do
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

  describe "#features" do
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
        expect(response.body).to include report_data[:total_live_forms].to_s
      end
    end
  end
end
