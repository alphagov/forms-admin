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
    end
end
