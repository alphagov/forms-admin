require "rails_helper"

describe "/memberships", type: :request do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:logged_in_user_role) { :group_admin }

  before do
    create(:membership, user: editor_user, group:, role: logged_in_user_role)
    login_as_editor_user
  end

  describe "#destroy" do
    it "deletes a membership" do
      membership = create(:membership, user:, group:, added_by: editor_user)

      expect {
        delete membership_path(membership)
      }.to change(Membership, :count).by(-1)

      expect(response).to redirect_to(group_members_path(group.external_id))
    end

    context "when logged in user is not a group admin" do
      let(:logged_in_user_role) { :editor }

      it "does not delete a membership" do
        membership = create(:membership, user:, group:, added_by: editor_user)

        expect {
          delete membership_path(membership)
        }.not_to change(Membership, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
