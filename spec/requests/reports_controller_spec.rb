require "rails_helper"

RSpec.describe ReportsController, type: :request do
  before do
    login_as_super_admin_user

    get report_features_path
  end

  describe "#features" do
    it "returns http code 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the features report view" do
      expect(response).to render_template("reports/features")
    end
  end
end
