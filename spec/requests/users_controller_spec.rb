require "rails_helper"

RSpec.describe UsersController, type: :request do
  describe "#index" do
    context "when logged in as a super admin" do
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

    context "when logged in without super admin role" do
      it "is forbidden" do
        login_as_editor_user
        get users_path
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#edit" do
    let(:user) { create(:user) }

    context "when logged in as a super admin" do
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

    context "when logged in without super admin role" do
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

    context "when logged in as a super admin" do
      before do
        login_as_super_admin_user
      end

      it "redirects to /users page and updates user" do
        put user_path(user), params: { user: { role: } }
        expect(response).to redirect_to(users_path)
        expect(user.reload.super_admin?).to be true
      end

      it "when given a user which doesn't exist returns 404" do
        put user_path(-1), params: { user: { role: } }
        expect(response).to have_http_status(:not_found)
      end

      it "does not update user if role is invalid" do
        put user_path(user), params: { user: { role: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include "Select a role for the user"
        expect(user.reload.role).not_to eq(nil)
      end

      context "when user belongs to an organistion" do
        it "does not update user if organisation is not chosen" do
          put user_path(user), params: { user: { organisation_id: nil } }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include "Select the user’s organisation"
          expect(user.reload.organisation).not_to eq(nil)
        end
      end

      [
        ["with an unknown organisation", :with_unknown_org],
        ["with no organisation set", :with_no_org],
      ].each do |(title, trait)|
        context "with a user #{title}" do
          let(:user) { create(:user, trait) }

          it "does not return error if organisation is not chosen" do
            put user_path(user), params: { user: { organisation_id: nil } }
            expect(response).to redirect_to(users_path)
            expect(user.reload.organisation).to eq(nil)
          end
        end
      end
    end

    context "when logged in without super admin role" do
      it "is forbidden" do
        login_as_editor_user
        put user_path(user), params: { user: { role: "super_admin" } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
