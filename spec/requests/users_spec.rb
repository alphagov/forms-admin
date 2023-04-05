require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "#index" do
    context "when user is a super_admin" do
      before do
        login_as_super_admin_user
        get "/users"
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the corect page" do
        expect(response.body).to include("Users")
        expect(response).to render_template("users/index")
      end
    end

    context "when user is not a super_admin" do
      it "does not allow access regular users" do
        login_as_editor_user
        get "/users"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
