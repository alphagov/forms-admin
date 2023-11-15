require "rails_helper"

RSpec.describe AuthenticationController, type: :request do
  before do
    Warden::Strategies.add(:mock_not_logged_in) do
      def valid?
        false
      end

      def authenticate!
        raise NotImplementedError
      end
    end

    allow(Settings).to receive(:auth_provider).and_return("mock_not_logged_in")

    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  let(:controller_spy) do
    controller_spy = described_class.new
    allow(described_class).to receive(:new).and_return(controller_spy)
    controller_spy
  end

  describe "#redirect_to_omniauth" do
    before do
      allow(controller_spy).to receive(:redirect_to_omniauth).and_call_original

      logout
    end

    it "is called by Warden if user is not logged in" do
      get root_path

      expect(controller_spy).to have_received(:redirect_to_omniauth)
    end

    it "redirects to OmniAuth request phase" do
      get root_path

      expect(response).to redirect_to("/auth/#{Settings.auth_provider}")
    end

    it "uses the configured OmniAuth provider" do
      allow(Settings).to receive(:auth_provider).and_return("auth0")

      get root_path

      expect(response).to redirect_to("/auth/auth0")
    end

    it "stores the URL the user is trying to reach for after they have signed in" do
      allow(Settings).to receive(:auth_provider).and_return("auth0")

      get live_form_pages_path(42)

      expect(response).to redirect_to("/auth/auth0")
      get "/auth/auth0"

      expect(response).to redirect_to("/auth/auth0/callback")
      get "/auth/auth0/callback"

      expect(response).to redirect_to(live_form_pages_path(42))
    end

    context "when the auth provider is auth0" do
      context "and the user is the end to end test user" do
        it "uses the Auth0 username/password flow" do
          allow(Settings).to receive(:auth_provider).and_return("auth0")

          get root_path, params: { auth: "e2e" }

          expect(response).to redirect_to("/auth/auth0?connection=Username-Password-Authentication")
        end
      end

      context "and the user is not the end to end test user" do
        it "uses the Auth0 passwordless flow" do
          allow(Settings).to receive(:auth_provider).and_return("auth0")

          get root_path

          expect(response).to redirect_to("/auth/auth0")
        end
      end
    end

    context "when the user's session expires" do
      before do
        allow(controller_spy).to receive(:redirect_to_omniauth).and_call_original

        # shorten the auth_valid_for time for testing
        GDS::SSO::Config.auth_valid_for = 1

        logout
      end

      after do
        GDS::SSO::Config.auth_valid_for = Settings.auth_valid_for
      end

      it "re-authenticates after the configured time" do
        login_as_editor_user

        get root_path

        expect(controller_spy).not_to have_received(:redirect_to_omniauth)

        # wait for the auth_valid_for time to pass
        sleep(1)

        get root_path

        expect(controller_spy).to have_received(:redirect_to_omniauth).once
      end
    end
  end

  describe "#callback_from_omniauth" do
    it "is called by OmniAuth provider" do
      get "/auth/gds"

      expect(response).to redirect_to("/auth/gds/callback")

      allow(controller_spy).to receive(:callback_from_omniauth).and_call_original

      get "/auth/gds/callback"

      expect(controller_spy).to have_received :callback_from_omniauth
    end

    it "calls Warden strategy" do
      allow(controller_spy).to receive(:authenticate_user!).and_call_original

      get "/auth/test/callback"

      expect(controller_spy).to have_received(:authenticate_user!)
    end
  end

  describe "#sign_up" do
    it "redirects to auth0 sign up page when using auth0" do
      allow(Settings).to receive(:auth_provider).and_return("auth0")

      get sign_up_path

      expect(response).to redirect_to "/auth/auth0?screen_hint=signup"
    end

    it "redirects user to homepage after they have signed up" do
      allow(Settings).to receive(:auth_provider).and_return("auth0")

      get sign_up_path

      expect(response).to redirect_to "/auth/auth0?screen_hint=signup"
      get "/auth/auth0?screen_hint=signup"

      expect(response).to redirect_to("/auth/auth0/callback?screen_hint=signup")
      get "/auth/auth0/callback?screen_hint=signup"

      expect(response).to redirect_to(root_path)
    end

    it "signs the user in after they have signed up" do
      allow(Settings).to receive(:auth_provider).and_return("auth0")

      get sign_up_path

      expect(response).to redirect_to "/auth/auth0?screen_hint=signup"
      get "/auth/auth0?screen_hint=signup"

      expect(response).to redirect_to("/auth/auth0/callback?screen_hint=signup")
      get "/auth/auth0/callback?screen_hint=signup"

      expect(request.env["warden"]).to be_authenticated
    end

    it "redirects to sign in page when not using auth0" do
      allow(Settings).to receive(:auth_provider).and_return("mock_not_logged_in")

      get sign_up_path

      expect(response).to redirect_to "/auth/mock_not_logged_in"
    end
  end

  describe "#sign_out" do
    let(:user) do
      create :user, provider: :test_provider
    end

    before do
      login_as user

      get new_form_path # populate the user session
    end

    it "clears the user session" do
      without_partial_double_verification do
        allow(controller_spy)
          .to receive(:test_provider_sign_out_url)
          .and_return("http://test.org/sign-out")

        expect(session).to include("warden.user.default.key")

        get sign_out_path

        expect(session).not_to include("warden.user.default.key")
      end
    end

    it "redirects the user to sign out of their auth provider" do
      without_partial_double_verification do
        allow(controller_spy)
          .to receive(:test_provider_sign_out_url)
          .and_return("http://test.org/sign-out")

        get sign_out_path

        expect(response).to redirect_to("http://test.org/sign-out")
      end
    end

    it "raises error if sign out URL not defined for provider" do
      expect { get sign_out_path }.to raise_error NoMethodError
    end

    it "redirects users who are not signed in to the home page" do
      reset!

      get sign_out_path

      expect(response).to redirect_to("/")
    end
  end
end
