require "rails_helper"

RSpec.describe "authentication using Warden and OmniAuth" do
  before do
    allow(Settings).to receive(:auth_provider).and_return("auth0")
  end

  after do
    OmniAuth.config.mock_auth[:auth0] = nil
    OmniAuth.config.test_mode = false
  end

  describe "when there is an OmniAuth failure" do
    it "raises an exception" do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:auth0] = :invalid_credentials

      logout

      get root_path

      expect(response).to redirect_to "/auth/auth0"
      follow_redirect!

      expect(response).to redirect_to "/auth/auth0/callback"
      expect { follow_redirect! }.to raise_error OmniAuth::Error
    end

    it "renders the sign_in_failed error page" do
      Rails.application.config.consider_all_requests_local = false
      Rails.application.config.action_dispatch.show_exceptions = true

      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:auth0] = :invalid_credentials

      logout

      get root_path

      expect(response).to redirect_to "/auth/auth0"
      follow_redirect!

      expect(response).to redirect_to "/auth/auth0/callback"
      follow_redirect!

      expect(response).to have_rendered "errors/sign_in_failure"
      expect(response).to have_http_status :bad_request
    end
  end
end
