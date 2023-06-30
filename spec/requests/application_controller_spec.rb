require "rails_helper"

RSpec.describe ApplicationController, type: :request do
  let(:headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  let(:form) { build :form, id: 1 }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms?org=test-org", headers, [form].to_json, 200
      mock.get "/api/v1/forms/1", headers, form.to_json, 200
      mock.get "/api/v1/forms/1/pages", headers, form.pages.to_json, 200
    end

    login_as_editor_user
  end

  context "when the service is in maintenance mode" do
    let(:bypass_ips) { " " }
    let(:expect_response_to_redirect) { true }
    let(:user_ip) { "192.0.0.2" }

    before do
      allow(Settings.maintenance_mode).to receive(:enabled).and_return(true)
      allow(Settings.maintenance_mode).to receive(:bypass_ips).and_return(bypass_ips)

      get root_path, headers: { "HTTP_X_FORWARDED_FOR": user_ip }
      follow_redirect! if expect_response_to_redirect
    end

    it "returns http code 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the maintenance page" do
      expect(response).to render_template("errors/maintenance")
    end

    context "when bypass ip range does not cover the user's ip" do
      let(:bypass_ips) { "192.0.0.0/32, 123.123.123.123/32" }

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the maintenance page" do
        expect(response).to render_template("errors/maintenance")
      end
    end

    context "when the  bypass ip range does include the user's ip" do
      let(:bypass_ips) { "192.0.0.0/29, 123.123.123.123/32" }
      let(:expect_response_to_redirect) { false }

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the root page" do
        expect(response).to render_template("forms/index")
      end
    end
  end

  context "when a user is logged in who does not have access" do
    let(:user) { build :user, :super_admin, has_access: false }

    before do
      login_as user
    end

    [
      "/",
      "/users",
      "/forms/1",
    ].each do |path|
      context "when accessing #{path}" do
        before do
          get path
        end

        it "returns http code 403 for #{path}" do
          expect(response).to have_http_status(:forbidden)
        end

        it "renders the access denied page" do
          expect(response).to render_template("errors/access_denied")
        end
      end
    end
  end
end
