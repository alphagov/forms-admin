require "rails_helper"

RSpec.describe ActAsUserController, type: :request do
  let(:act_as_user_enabled) { true }

  before do
    allow(Settings).to receive(:act_as_user_enabled).and_return(act_as_user_enabled)
    login_as_super_admin_user
  end

  describe "POST start" do
    context "when the act_as_user_enabled setting is off" do
      let(:act_as_user_enabled) { false }

      it "raises an error" do
        post act_as_user_start_path(trial_user)

        expect(response).to have_http_status(404)
      end
    end

    context "when the user is not a super_admin" do
      before do
        login_as_editor_user
      end

      it "redirects to the root page" do
        post act_as_user_start_path(trial_user)

        expect(response).to have_http_status(403)
      end
    end

    context "when the target user is a super_admin" do
      let(:other_super_admin) { create(:super_admin_user) }

      it "returns an unauthorized response" do
        post act_as_user_start_path(other_super_admin)

        expect(request.env["warden"].user.id).to eq(super_admin_user.id)
      end
    end

    it "changes the acting user" do
      post act_as_user_start_path(trial_user)

      expect(request.env["warden"].user.id).to eq(trial_user.id)
      expect(session[:original_user_id]).to eq(super_admin_user.id)
    end
  end
end
