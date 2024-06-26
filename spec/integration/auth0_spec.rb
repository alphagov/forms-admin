require "rails_helper"

RSpec.describe "usage of omniauth-auth0 gem" do
  include AuthenticationFeatureHelpers

  before do
    set_run_callbacks(true)
    allow(Settings).to receive(:auth_provider).and_return("auth0")
    OmniAuth.config.test_mode = true
  end

  after do
    set_run_callbacks(false)
    OmniAuth.config.mock_auth[:auth0] = nil
    OmniAuth.config.test_mode = false
  end

  let(:omniauth_hash) do
    Faker::Omniauth.auth0(
      uid: "123456",
      email: "test@example.com",
    )
  end

  describe "authentication" do
    it "redirects to OmniAuth when no user is logged in" do
      logout

      get root_path

      expect(response).to redirect_to(sign_in_path)
    end

    it "authenticates with OmniAuth and Warden" do
      OmniAuth.config.mock_auth[:auth0] = omniauth_hash

      post "/auth/auth0"

      expect(response).to redirect_to("/auth/auth0/callback")

      get "/auth/auth0/callback"

      expect(request.env["warden"].authenticated?).to be true
    end
  end

  describe "signing out" do
    before do
      OmniAuth.config.mock_auth[:auth0] = omniauth_hash
      post "/auth/auth0"
      get "/auth/auth0/callback"
    end

    it "signs the user out of auth0" do
      allow(Settings.auth0).to receive_messages(domain: "test", client_id: "baz")

      get sign_out_path

      expect(response).to redirect_to("https://test/v2/logout?client_id=baz&returnTo=http%3A%2F%2Fwww.example.com%2F")
    end
  end

  describe User do
    describe ".find_for_auth" do
      it "is called by the auth0 Warden strategy" do
        allow(described_class).to receive(:find_for_auth).and_call_original

        OmniAuth.config.mock_auth[:auth0] = omniauth_hash

        post "/auth/auth0"
        get "/auth/auth0/callback"

        expect(described_class).to have_received(:find_for_auth).with(
          provider: "auth0",
          uid: "123456",
          email: "test@example.com",
        )

        winning_strategy = request.env["warden"].winning_strategy
        expect(winning_strategy).to be_a Warden::Strategies[:auth0]
        expect(winning_strategy).to be_successful
      end
    end
  end

  describe "failure page" do
    it "is shown if there is an authentication failure with external provider" do
      OmniAuth.config.mock_auth[:auth0] = :invalid_credentials

      logout

      post "/auth/auth0"

      expect(response).to redirect_to "/auth/auth0/callback"
      follow_redirect!

      expect(response).to redirect_to "/auth/failure?message=invalid_credentials&strategy=auth0"
    end

    it "has a retry link" do
      get "/auth/failure?message=invalid_credentials&strategy=auth0"

      expect(response.body).to include '<a href="/auth/auth0">try again</a>'
    end
  end

  describe "Auth0 client selection" do
    before do
      allow(Settings).to receive(:auth0).and_return(
        OpenStruct.new(
          client_id: "1234",
          client_secret: "abcd",
          e2e_client_id: "4321",
          e2e_client_secret: "dcba",
        ),
      )

      OmniAuth.config.mock_auth[:auth0] = omniauth_hash
    end

    it "uses e2e client when auth is set to e2e" do
      get "/auth/auth0/callback", params: { auth: "e2e" }

      strategy = request.env["omniauth.strategy"]

      expect(strategy.options[:client_id]).to eq("4321")
      expect(strategy.options[:client_secret]).to eq("dcba")
      expect(strategy.options[:callback_path]).to eq("/auth/auth0/callback?auth=e2e")
      expect(strategy.options[:authorize_params][:connection]).to be_nil
    end

    it "uses default client when auth is not set to e2e" do
      get "/auth/auth0/callback"

      strategy = request.env["omniauth.strategy"]

      expect(strategy.options[:client_id]).to eq("1234")
      expect(strategy.options[:client_secret]).to eq("abcd")
      expect(strategy.options[:callback_path]).to eq("/auth/auth0/callback")
      expect(strategy.options[:authorize_params][:connection]).to be_nil
    end
  end

  describe "Google workspace integration" do
    let(:form) { build :form, :with_active_resource, id: 1, name: "Apply for a juggling license" }
    let(:org_forms) { [] }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms?organisation_id=1", api_get_request_headers, org_forms.to_json, 200
      end
    end

    context "when a super-admin user is logged in" do
      let(:user) { super_admin_user }

      context "and authenticated via Google" do
        [
          "/groups",
          "/users",
        ].each do |path|
          it "when accessing #{path}, returns http code 200 for #{path}" do
            user.provider = "auth0"
            omniauth_hash[:info][:email] = user.email
            omniauth_hash[:extra][:raw_info][:auth0_connection_strategy] = "google-apps"

            OmniAuth.config.mock_auth[:auth0] = omniauth_hash

            post "/auth/auth0"

            expect(response).to redirect_to("/auth/auth0/callback")

            get "/auth/auth0/callback"

            get path

            expect(response).to have_http_status(:ok)
          end
        end
      end

      context "and didn't authenticate via Google" do
        [
          "/",
          "/users",
        ].each do |path|
          context "when accessing #{path}" do
            before do
              user.provider = "auth0"
              omniauth_hash[:info][:email] = user.email
              omniauth_hash[:extra][:raw_info][:auth0_connection_strategy] = "email"

              OmniAuth.config.mock_auth[:auth0] = omniauth_hash

              post "/auth/auth0"

              get "/auth/auth0/callback"

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
      end
    end

    context "when a non-super-admin user is logged in" do
      let(:user) { editor_user }

      context "and authenticated via Google" do
        context "when accessing /groups," do
          %w[google-apps invalid-connection].each do |connection|
            context "and using #{connection}," do
              it "returns http code 200" do
                user.provider = "auth0"
                omniauth_hash[:info][:email] = user.email
                omniauth_hash[:extra][:raw_info][:auth0_connection_strategy] = connection

                OmniAuth.config.mock_auth[:auth0] = omniauth_hash

                post "/auth/auth0"

                expect(response).to redirect_to("/auth/auth0/callback")

                get "/auth/auth0/callback"

                get groups_path

                expect(response).to have_http_status(:ok)
              end
            end
          end
        end
      end
    end
  end
end
