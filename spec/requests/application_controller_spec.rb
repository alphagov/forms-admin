require "rails_helper"

RSpec.describe ApplicationController, type: :request do
  let(:form) { build :form, id: 1 }

  let(:output) { StringIO.new }
  let(:logger) { ActiveSupport::Logger.new(output) }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms?organisation_id=1", headers, [form].to_json, 200
      mock.get "/api/v1/forms/1", headers, form.to_json, 200
      mock.get "/api/v1/forms/1/pages", headers, form.pages.to_json, 200
    end

    login_as_standard_user
  end

  describe "logging" do
    let(:trace_id) { "Root=1-63441c4a-abcdef012345678912345678" }
    let(:request_id) { "a-request-id" }

    before do
      # Intercept the request logs so we can do assertions on them
      allow(Lograge).to receive(:logger).and_return(logger)
    end

    context "when the request does not have a form_id parameter" do
      before do
        get root_path, headers: {
          "HTTP_X_AMZN_TRACE_ID": trace_id,
          "X-Request-ID": request_id,
        }
      end

      it "includes the trace ID on log lines" do
        expect(log_lines[0]["trace_id"]).to eq(trace_id)
      end

      it "includes the request_id on log lines" do
        expect(log_lines[0]["request_id"]).to eq(request_id)
      end

      it "includes the host on log lines" do
        expect(log_lines[0]["host"]).to eq("www.example.com")
      end

      it "includes the user_id on log lines" do
        expect(log_lines[0]["user_id"]).to eq(standard_user.id)
      end

      it "includes the user_email on log lines" do
        expect(log_lines[0]["user_email"]).to eq(standard_user.email)
      end

      it "includes the user_organisation_slug on log lines" do
        expect(log_lines[0]["user_organisation_slug"]).to eq(standard_user.organisation.slug)
      end
    end

    context "when the request has a form_id parameter" do
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/#{form.id}", headers, form.to_json, 200
        end
      end

      it "includes the form_id on log lines" do
        get form_path(form.id)
        expect(log_lines[0]["form_id"]).to eq(form.id.to_s)
      end

      context "when form is not in a group" do
        it "does not include the form_organisation_id on log lines" do
          get form_path(form.id)
          expect(log_lines[0]["form_organisation_id"]).to be_nil
        end
      end

      context "when form is in a group" do
        let(:organisation) { create(:organisation) }
        let(:group) { create(:group, id: 11, organisation:) }

        before do
          GroupForm.create!(form_id: form.id, group:)
          get form_path(form.id)
        end

        it "includes the form_organisation_id on log lines" do
          expect(log_lines[0]["form_organisation_id"]).to eq(organisation.id)
        end
      end
    end

    context "when the request has a page_id parameter" do
      let(:page) { build :page, id: 33 }

      before do
        get edit_question_path(form.id, page.id)
      end

      it "includes the page_id on log lines" do
        expect(log_lines[0]["page_id"]).to eq(page.id.to_s)
      end
    end
  end

  context "when the service is in maintenance mode" do
    let(:bypass_ips) { " " }
    let(:expect_response_to_redirect) { true }
    let(:user_ip) { "192.0.0.2" }

    before do
      allow(Settings.maintenance_mode).to receive_messages(enabled: true, bypass_ips:)

      get groups_path, headers: { "HTTP_X_FORWARDED_FOR": user_ip }
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

    context "when the bypass ip range does include the user's ip" do
      let(:bypass_ips) { "192.0.0.0/29, 123.123.123.123/32" }
      let(:expect_response_to_redirect) { false }

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the root page" do
        expect(response).to render_template("groups/index")
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
          expect(response.body).to include("if you think this is incorrect.")
        end
      end
    end

    context "when a user is logged in from an access restricting organisation" do
      let(:user) { create :user, email: User::EMAIL_DOMAIN_DENYLIST.first }

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

          it "renders the access denied by organisation page" do
            expect(response).to render_template("errors/access_denied")
            expect(response.body).to include(I18n.t("forbidden.body_html_org_restricted"))
          end
        end
      end
    end
  end

  context "when a user is logged in who does not have organisation set" do
    let(:user) { create :user, :with_no_org, name: nil }

    before do
      login_as user
    end

    it "redirects to the account organisation page" do
      get root_path
      expect(response).to redirect_to(edit_account_organisation_path)
    end
  end

  describe "#up" do
    it "returns http code 200" do
      get rails_health_check_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "footer" do
    it "contains links related to the service" do
      get root_path

      expect(response.body).to include('<a class="govuk-footer__link" href="https://www.forms.service.gov.uk/accessibility">Accessibility statement</a>')
      expect(response.body).to include('<a class="govuk-footer__link" href="https://www.forms.service.gov.uk/cookies">Cookies</a>')
      expect(response.body).to include('<a class="govuk-footer__link" href="https://www.forms.service.gov.uk/privacy">Privacy</a>')
      expect(response.body).to include('<a class="govuk-footer__link" href="https://www.forms.service.gov.uk/terms-of-use">Terms of use</a>')
    end
  end

  def log_lines
    output.string.split("\n").map { |line| JSON.parse(line) }
  end
end
