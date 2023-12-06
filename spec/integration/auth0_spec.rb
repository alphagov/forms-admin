require "rails_helper"

RSpec.describe "usage of omniauth-auth0 gem" do
  before do
    allow(Settings).to receive(:auth_provider).and_return("auth0")

    OmniAuth.config.test_mode = true
  end

  after do
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
      allow(Settings.auth0).to receive(:domain).and_return("test")
      allow(Settings.auth0).to receive(:client_id).and_return("baz")

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
end
