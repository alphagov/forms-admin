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

    context "when logged in with standard role" do
      it "is forbidden" do
        login_as_standard_user
        get users_path
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "with many users" do
      before do
        login_as_super_admin_user

        organisations = [
          create(:organisation, :with_signed_mou, slug: "test-org"),
          create(:organisation, :with_signed_mou, slug: "ministry-of-tests"),
          create(:organisation, :with_signed_mou, slug: "department-for-testing"),
        ]
        roles = User.roles.keys

        organisations.each_with_index.flat_map do |organisation|
          roles.each_with_index.flat_map do |role|
            create_list(:user, 5, organisation:, role:) do |user, i|
              user.has_access = i < 4
              user.save!
            end
          end
        end

        get users_path
      end

      it "sorts users by organisation, access, role, and name" do
        assigns[:users].each_cons(2) do |user, next_user|
          if user.organisation.name == next_user.organisation.name
            if user.has_access == next_user.has_access
              if user.role == next_user.role
                expect(user.name).to be <= next_user.name
              else
                case user.role
                when "super_admin" then expect(next_user.role).to eq "organisation_admin"
                when "organisation_admin" then expect(next_user.role).to eq "standard"
                end
              end
            else
              expect(next_user.has_access).to be false
            end
          else
            expect(user.organisation.name < next_user.organisation.name)
          end
        end
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

    context "when logged in with standard role" do
      it "is forbidden" do
        login_as_standard_user
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

      it "can update the user's name" do
        patch user_path(user), params: { user: { name: "Fakey McFakeName" } }
        expect(user.reload.name).to eq "Fakey McFakeName"
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
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include "Select a role for the user"
        expect(user.reload.role).not_to be_nil
      end

      context "when user has a name" do
        it "does not update user if name is cleared" do
          put user_path(user), params: { user: { name: nil } }
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include "Enter the user’s name"
          expect(user.reload.organisation).not_to be_nil
        end
      end

      context "when user belongs to an organistion" do
        it "does not update user if organisation is not chosen" do
          put user_path(user), params: { user: { organisation_id: nil } }
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include "Select the user’s organisation"
          expect(user.reload.organisation).not_to be_nil
        end
      end

      context "with a user with no name set" do
        let(:user) { create(:user, name: nil) }

        it "successfully updates the user when a name is not set" do
          put user_path(user), params: { user: { name: nil } }
          expect(response).to redirect_to(users_path)
          expect(user.reload.name).to be_nil
        end
      end

      context "with a user with no organisation set" do
        let(:user) { create(:user, organisation_id: nil) }

        it "does not return error if organisation is not chosen and role is not changed" do
          put user_path(user), params: { user: { organisation_id: nil } }
          expect(response).to redirect_to(users_path)
          expect(user.reload.organisation).to be_nil
        end

        it "returns an error if organisation is not chosen and role is changed to organisation_admin" do
          put user_path(user), params: { user: { role: "organisation_admin", organisation_id: nil } }
          expect(response).to have_http_status(:unprocessable_content)
          expect(user.reload.role).to eq("standard")
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
            expect(user.reload.organisation).to be_nil
          end
        end
      end
    end

    context "when logged in with standard role" do
      it "is forbidden" do
        login_as_standard_user
        put user_path(user), params: { user: { role: "super_admin" } }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when changing role" do
      before do
        login_as_super_admin_user
      end

      it "calls UserUpdateService" do
        user = create(:user)
        user_update_service = instance_spy(UserUpdateService)

        allow(UserUpdateService)
          .to receive(:new)
          .with(user, ActionController::Parameters.new(role: "organisation_admin").permit(:role))
          .and_return(user_update_service)

        patch user_path(user), params: { user: { role: "organisation_admin" } }

        expect(UserUpdateService)
          .to have_received(:new)
          .with(user, ActionController::Parameters.new(role: "organisation_admin").permit(:role))

        expect(user_update_service)
          .to have_received(:update_user)
      end
    end
  end
end
