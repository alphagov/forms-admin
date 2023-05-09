require "rails_helper"

RSpec.describe UsersController, type: :request do
  describe "#index" do
    context "when user is a super_admin" do
      before do
        login_as_super_admin_user
        get users_path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the correct page" do
        expect(response.body).to include("Users")
        expect(response).to render_template("users/index")
      end
    end

    context "when user is not a super_admin" do
      it "is forbidden" do
        login_as_editor_user
        get users_path
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#edit" do
    let(:user) { create(:user) }

    context "when user is a super_admin" do
      before do
        login_as_super_admin_user
        get edit_user_path(user)
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the correct page" do
        expect(response).to render_template("users/edit")
      end
    end

    context "when user is not a super_admin" do
      it "is forbidden" do
        login_as_editor_user
        get edit_user_path(user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#update" do
    let(:user) { create(:user) }
    let(:role) { :super_admin }

    context "when user is a super_admin" do
      before do
        login_as_super_admin_user
      end

      it "redirects to /users page and updates user" do
        put user_path(user), params: { user: { role: } }
        expect(response).to redirect_to(users_path)
        # TODO: This can change to .super_admin? after phase 2
        expect(user.reload.role).to eq("super_admin")
      end

      it "when given a user which doesn't exist returns 404" do
        put user_path(-1), params: { user: { role: } }
        expect(response).to have_http_status(:not_found)
      end

      it "does not update user if role is invalid" do
        put user_path(user), params: { user: { role: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.reload.role).not_to eq(nil)
      end
    end

    context "when user is not a super_admin" do
      it "is forbidden" do
        login_as_editor_user
        put user_path(user), params: { user: { role: "super_admin" } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
