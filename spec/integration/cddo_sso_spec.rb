require "rails_helper"

RSpec.describe "usage of cddo_sso auth provider" do
  let(:omniauth_hash) do
    OmniAuth::AuthHash.new({
      provider: "cddo_sso",
      uid: "123456",
      info: {
        email: "test@example.com",
        name: "Test User",
      },
    })
  end

  before do
    allow(Settings).to receive(:auth_provider).and_return("cddo_sso")

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:cddo_sso] = nil
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe "authentication" do
    it "redirects to OmniAuth when no user is logged in" do
      logout

      get root_path

      expect(response).to redirect_to("/auth/cddo_sso")
    end

    it "authenticates with OmniAuth and Warden" do
      OmniAuth.config.mock_auth[:cddo_sso] = omniauth_hash

      get "/auth/cddo_sso"

      expect(response).to redirect_to("/auth/cddo_sso/callback")

      get "/auth/cddo_sso/callback"

      expect(request.env["warden"].authenticated?).to be true
    end

    it "redirects to the OmniAuth callback URL" do
      OmniAuth.config.test_mode = false

      allow(Settings.cddo_sso).to receive(:identifier).and_return("foo")
      allow(Settings.cddo_sso).to receive(:secret).and_return("bar")

      get "/auth/cddo_sso"

      expect(response).to redirect_to %r{^https://sso\.service\.security\.gov\.uk}
      expect(response).to redirect_to %r{redirect_uri=http%3A%2F%2Fwww\.example\.com%2Fauth%2Fcddo_sso%2Fcallback}
    end
  end

  describe "signing out" do
    before do
      OmniAuth.config.mock_auth[:cddo_sso] = omniauth_hash
      get "/auth/cddo_sso"
      get "/auth/cddo_sso/callback"
    end

    it "signs the user out of sso.service.security.gov.uk" do
      allow(Settings.cddo_sso).to receive(:identifier).and_return("baz")

      get sign_out_path

      expect(response).to redirect_to("https://sso.service.security.gov.uk/sign-out?from_app=baz")
    end
  end

  describe User do
    describe ".find_for_auth" do
      it "is called by the cddo_sso Warden strategy" do
        allow(described_class).to receive(:find_for_auth).and_call_original

        OmniAuth.config.mock_auth[:cddo_sso] = omniauth_hash
        get "/auth/cddo_sso"
        get "/auth/cddo_sso/callback"

        expect(described_class).to have_received(:find_for_auth).with(
          provider: "cddo_sso",
          uid: "123456",
          email: "test@example.com",
          name: "Test User",
        )

        expect(request.env["warden"].winning_strategy.successful?).to be true
      end
    end
  end
end
