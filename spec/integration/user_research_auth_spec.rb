require "rails_helper"

RSpec.describe "authenticating in user research environment" do
  before do
    allow(Settings).to receive_messages(auth_provider: "user_research", forms_env: "user-research")
  end

  specify "app redirects to sign in when no user is logged in" do
    logout

    get root_path

    expect(response).to redirect_to sign_in_path
  end

  specify "app renders sign in form when no user is logged in" do
    post "/auth/user-research"

    expect(response).to have_http_status(200)
    expect(response.body).to include "<form"
  end

  describe "sigining in" do
    it "checks credentials against settings for user research auth" do
      post "/auth/user-research/callback", params: { username: Settings.user_research.auth.username, password: Settings.user_research.auth.password }

      expect(request.env["warden"].authenticated?).to be true
    end

    it "does not authenticate the user if the credentials do not match" do
      post "/auth/user-research/callback", params: { username: "notauser", password: "bogus" }

      expect(request.env["warden"].authenticated?).to be false
      expect(response).to redirect_to "/auth/failure?message=invalid_credentials&strategy=user-research"
    end

    it "does not authenticate the user if the app is not in the user research environment" do
      allow(Settings).to receive(:forms_env).and_return("production")

      post "/auth/user-research/callback", params: { username: Settings.user_research.auth.username, password: Settings.user_research.auth.password }

      expect(request.env["warden"].authenticated?).to be false
    end

    it "signs in user as defined in settings" do
      post "/auth/user-research/callback", params: { username: Settings.user_research.auth.username, password: Settings.user_research.auth.password }

      expect(assigns[:current_user].name).to eq Settings.user_research.auth.username
      expect(assigns[:current_user].role.to_sym).to eq :standard
      expect(assigns[:current_user].organisation.slug).to eq Settings.user_research.organisation.slug
    end
  end

  describe "signing out" do
    before do
      post "/auth/user-research/callback", params: { username: Settings.user_research.auth.username, password: Settings.user_research.auth.password }
    end

    specify "there is a sign out link in the page header" do
      get root_path

      rendered = Capybara.string(response.body)

      expect(rendered.find(".govuk-header")).to have_link href: sign_out_path
    end

    specify "signing out redirects to the sign in page" do
      get sign_out_path

      follow_redirect!

      expect(response).to redirect_to(sign_in_path)
    end
  end
end
