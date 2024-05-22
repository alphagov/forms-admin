require "rails_helper"

RSpec.describe "/groups/:group_id/members", type: :request, feature_groups: true do
  let(:group) { create :group, organisation: current_user.organisation }
  let(:role) { :group_admin }
  let(:current_user) { editor_user }

  let(:nonexistent_group) { "foobar" }

  before do
    create(:membership, user: current_user, group:, role:)
    login_as current_user
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

    context "when there is no group with the given ID" do
      it "renders a 404 not found response" do
        get group_members_url(nonexistent_group)
        expect(response).to have_http_status :not_found
      end
    end

    context "when the groups feature flag is disabled", feature_groups: false do
      it "returns a 404 response" do
        get group_members_url(group)
        expect(response).to have_http_status(:not_found)
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

    context "when there is no group with the given ID" do
      it "renders a 404 not found response" do
        get new_group_member_url(nonexistent_group)
        expect(response).to have_http_status :not_found
      end
    end

    context "when the groups feature flag is disabled", feature_groups: false do
      it "returns a 404 response" do
        get new_group_member_url(group)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /groups/:group_id/members" do
    let(:user) { create :user, organisation: editor_user.organisation }

    context "with valid parameters" do
      it "creates a new membership" do
        expect {
          post group_members_url(group), params: { group_member_input: { member_email_address: user.email } }
        }.to change(Membership, :count).by(1)

        expect(response).to have_http_status :redirect
      end

      it "ignores role when group admin adds a member" do
        expect {
          post group_members_url(group), params: { group_member_input: { member_email_address: user.email, role: :group_admin } }
        }.to change(Membership, :count).by(1)

        expect(Membership.last.role).to eq "editor"
      end

      context "and I'm an editor" do
        let(:role) { :editor }

        it "denies access" do
          expect {
            post group_members_url(group), params: { group_member_input: { member_email_address: user.email } }
          }.not_to change(Membership, :count)

          expect(response).to have_http_status :forbidden
        end
      end

      context "and I'm an organisation admin" do
        let(:current_user) { organisation_admin_user }

        it "creates a new membership" do
          expect {
            post group_members_url(group), params: { group_member_input: { member_email_address: user.email, role: :group_admin } }
          }.to change(Membership, :count).by(1)

          expect(Membership.last.group_admin?).to be true

          expect(response).to have_http_status :redirect
        end
      end
    end

    context "with invalid parameters" do
      it "does not create a new membership" do
        expect {
          post group_members_url(group), params: { group_member_input: { member_email_address: "invalid" } }
        }.not_to change(Membership, :count)

        expect(response).to have_http_status :unprocessable_entity
        expect(response).to render_template :new
      end
    end

    context "when there is no group with the given ID" do
      it "renders a 404 not found response" do
        post group_members_url(nonexistent_group), params: { group_member_input: { member_email_address: user.email } }
        expect(response).to have_http_status :not_found
      end
    end

    context "when the groups feature flag is disabled", feature_groups: false do
      it "returns a 404 response" do
        post group_members_url(group), params: { group_member_input: { member_email_address: user.email } }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
