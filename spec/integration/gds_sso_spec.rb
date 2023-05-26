require "rails_helper"

RSpec.describe "usage of gds-sso gem" do
  let(:omniauth_hash) do
    OmniAuth::AuthHash.new({
      provider: "gds",
      uid: "123456",
      info: {
        email: "test@example.com",
        name: "Test User",
      },
      extra: {
        user: {
          permissions: ["---"],
          organisation_slug: "test-org",
          organisation_content_id: "00000000-0000-0000-0000-000000000000",
          disabled: false,
        },
      },
    })
  end

  describe "authentication" do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:gds] = nil
    end

    after do
      OmniAuth.config.test_mode = false
    end

    it "redirects to OmniAuth when no user is logged in" do
      logout

      get root_path

      expect(response).to redirect_to("/auth/gds")
    end

    it "authenticates with OmniAuth and Warden" do
      OmniAuth.config.mock_auth[:gds] = omniauth_hash

      get "/auth/gds"

      expect(response).to redirect_to(gds_sign_in_path)

      get gds_sign_in_path

      expect(request.env["warden"].authenticated?).to be true
    end
  end

  describe User do
    describe ".find_for_gds_oauth" do
      it "is called by the gds_sso Warden strategy" do
        allow(described_class).to receive(:find_for_gds_oauth).and_call_original
        allow(described_class).to receive(:find_for_auth).and_call_original

        gds_sso = Warden::Strategies[:gds_sso].new({
          "omniauth.auth" => omniauth_hash,
        })
        gds_sso.authenticate!

        expect(described_class).to have_received(:find_for_gds_oauth)

        expect(described_class).to have_received(:find_for_auth).with(
          uid: "123456",
          email: "test@example.com",
          name: "Test User",
          permissions: ["---"],
          organisation_slug: "test-org",
          organisation_content_id: "00000000-0000-0000-0000-000000000000",
          disabled: false,
        )

        expect(gds_sso.successful?).to be true
      end
    end
  end
end
