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

    context "when logged in with editor role" do
      it "is forbidden" do
        login_as_editor_user
        get users_path
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when logged in with trial role" do
      it "is forbidden" do
        login_as_trial_user
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

    context "when logged in with editor role" do
      it "is forbidden" do
        login_as_editor_user
        get edit_user_path(user)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when logged in with trial role" do
      it "is forbidden" do
        login_as_trial_user
        get edit_user_path(user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#update" do
    let(:user) { create(:user, role: :editor) }
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

      it "can update whether user has access" do
        patch user_path(user), params: { user: { has_access: false } }
        expect(user.reload.has_access).to be false
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

      context "with a trial user with no organisation set" do
        let(:user) { create(:user, :with_trial_role) }

        it "does not return error if organisation is not chosen and role is not changed" do
          put user_path(user), params: { user: { role: "trial", organisation_id: nil } }
          expect(response).to redirect_to(users_path)
          expect(user.reload.organisation).to eq(nil)
        end

        it "returns an error if organisation is not chosen and role is changed to editor" do
          put user_path(user), params: { user: { role: "editor", organisation_id: nil } }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(user.reload.role).to eq("trial")
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

    context "when logged in with editor role" do
      it "is forbidden" do
        login_as_editor_user
        put user_path(user), params: { user: { role: "super_admin" } }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when logged in with trial role" do
      it "is forbidden" do
        login_as_trial_user
        put user_path(user), params: { user: { role: "super_admin" } }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when changing role" do
      before do
        login_as_super_admin_user
      end

      User.roles.reject { |role| role == "trial" }.each do |_role_name, role_value|
        it "updates user's forms' org when changing role from trial to #{role_value}" do
          user = create(:user, role: :trial)
          expect(Form).to receive(:update_organisation_for_creator).with(user.id, user.organisation.id)

          patch user_path(user), params: { user: { role: role_value } }

          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(users_path)
        end

        it "does not update user's forms' org when changing role from #{role_value} to editor" do
          user = create :user, role: role_value

          expect(Form).not_to receive(:update_organisation_for_creator).with(user.id, user.organisation.id)

          patch user_path(user), params: { user: { role: "editor" } }

          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(users_path)
        end

        it "does not update user's forms' org when role is unchanged" do
          user = create :user, role: :trial

          expect(Form).to receive(:update_organisation_for_creator).with(user.id, user.organisation.id)

          patch user_path(user), params: { user: { role: "editor" } }

          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(users_path)

          expect(Form).not_to receive(:update_organisation_for_creator).with(user.id, user.organisation.id)
          patch user_path(user), params: { user: { role: "editor" } }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(users_path)
        end
      end
    end
  end
end
