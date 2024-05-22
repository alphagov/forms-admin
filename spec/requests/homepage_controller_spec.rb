require "rails_helper"

describe HomepageController, type: :request do
  before do
    login_as_editor_user
  end

  context "when the groups feature flag is enabled", feature_groups: true do
    before do
      get root_path
    end

    it "redirects to the groups index page" do
      expect(response).to redirect_to groups_path
    end
  end

  context "when the groups feature flag is disabled", feature_groups: false do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms?organisation_id=1", headers, {}.to_json, 200
      end
      get root_path
    end

    it "returns a 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the forms index page" do
      expect(response).to render_template("forms/index")
    end
  end
end
