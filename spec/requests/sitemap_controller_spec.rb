require "rails_helper"

RSpec.describe SitemapController, type: :request do
  describe "#index" do
    let(:path) { sitemap_path }

    context "when the user is a standard user" do
      before do
        login_as_standard_user

        get path
      end

      it "returns a success response and renders the index view" do
        expect(response).to have_http_status(:ok)
        expect(response).to render_template("sitemap/index")
        expect(response.body).to include "Sitemap"
      end
    end

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get path
      end

      it "returns a success response and renders the index view" do
        expect(response).to have_http_status(:ok)
        expect(response).to render_template("sitemap/index")
        expect(response.body).to include "Sitemap"
      end

      it "includes the Users link" do
        expect(response.body).to include "Users"
      end

      it "includes the MOUs link" do
        expect(response.body).to include "Memorandum of Understanding"
      end

      it "includes the Reports link" do
        expect(response.body).to include "Reports"
      end
    end
  end
end
