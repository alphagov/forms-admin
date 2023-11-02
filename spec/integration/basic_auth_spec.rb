require "rails_helper"

RSpec.describe "using basic auth" do
  let(:username) { "tester" }
  let(:password) { "password" }
  let(:basic_auth_user) { create :basic_auth_user, name: username, organisation_id: organisation.id }

  let(:organisation) do
    create :organisation
  end

  let(:basic_auth_settings) do
    Config::Options.new(
      organisation: Config::Options.new(
        slug: organisation.slug,
        name: organisation.name,
        govuk_content_id: organisation.govuk_content_id,
      ),
      username:,
      password:,
    )
  end

  before do
    api_headers = {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms?creator_id=#{basic_auth_user.id}", api_headers, [].to_json, 200
    end

    allow(Settings).to receive(:auth_provider).and_return("basic_auth")
  end

  it "app requests HTTP Basic Authentication when no user is logged in" do
    logout

    get root_path

    expect(response).to have_http_status(:unauthorized)
    expect(response.headers["WWW-Authenticate"]).to eq 'Basic realm="Application"'
  end

  describe "authentication" do
    before do
      allow(Settings).to receive(:basic_auth).and_return(basic_auth_settings)

      auth = ActionController::HttpAuthentication::Basic
        .encode_credentials(username, password)

      get root_path, headers: { "HTTP_AUTHORIZATION": auth }
    end

    it "authenticates with Warden" do
      expect(request.env["warden"].authenticated?).to be true
    end

    it "signs in user as defined in settings" do
      expect(assigns[:current_user].name).to eq basic_auth_user.name
      expect(assigns[:current_user].email).to eq basic_auth_user.email
      expect(assigns[:current_user].role.to_sym).to eq :trial
      expect(assigns[:current_user].organisation.slug).to eq basic_auth_user.organisation.slug
      expect(assigns[:current_user].provider).to eq basic_auth_user.provider
    end
  end
end
