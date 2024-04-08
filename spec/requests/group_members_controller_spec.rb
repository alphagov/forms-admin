require "rails_helper"

RSpec.describe "/groups/:group_id/members", type: :request do
  let(:group) { create :group }

  before do
    create(:membership, user: editor_user, group:)
    login_as_editor_user
  end

  describe "GET /groups/:group_id/members" do
    it "renders a successful response" do
      get group_members_url(group)
      expect(response).to be_successful
    end

    context "when the current user does not have access to the group" do
      it "denies access" do
        other_group = create :group

        get group_members_url(other_group)

        expect(response).to have_http_status :forbidden
      end
    end
  end
end
