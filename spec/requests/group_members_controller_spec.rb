require "rails_helper"

RSpec.describe "/groups/:group_id/members", type: :request do
  let(:group) { create :group, organisation: editor_user.organisation }
  let(:role) { :group_admin }

  before do
    create(:membership, user: editor_user, group:, role:)
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

  describe "GET /groups/:group_id/members/new" do
    it "renders a successful response" do
      get new_group_member_url(group)
      expect(response).to be_successful
    end

    context "and I'm an editor" do
      let(:role) { :editor }

      it "denies access" do
        get new_group_member_url(group)
        expect(response).to have_http_status :forbidden
      end
    end
  end

  describe "POST /groups/:group_id/members" do
    context "with valid parameters" do
      let(:user) { create :user, organisation: editor_user.organisation }

      it "creates a new membership" do
        expect {
          post group_members_url(group), params: { group_member_form: { member_email_address: user.email } }
        }.to change(Membership, :count).by(1)

        expect(response).to have_http_status :redirect
      end

      context "and I'm an editor" do
        let(:role) { :editor }

        it "denies access" do
          expect {
            post group_members_url(group), params: { group_member_form: { member_email_address: user.email } }
          }.not_to change(Membership, :count)

          expect(response).to have_http_status :forbidden
        end
      end
    end

    context "with invalid parameters" do
      it "does not create a new membership" do
        expect {
          post group_members_url(group), params: { group_member_form: { member_email_address: "invalid" } }
        }.not_to change(Membership, :count)

        expect(response).to have_http_status :unprocessable_entity
        expect(response).to render_template :new
      end
    end
  end
end
