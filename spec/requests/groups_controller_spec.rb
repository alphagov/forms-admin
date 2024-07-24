require "rails_helper"

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/groups", type: :request do
  let(:current_user) { editor_user }
  let(:role) { :editor }
  let(:status) { :trial }
  let(:upgrade_requester) {}
  let(:member_group) do
    create(:group, organisation: current_user.organisation, status:, upgrade_requester:).tap do |group|
      create(:membership, user: current_user, group:, role:)
    end
  end

  let(:non_member_group) do
    create :group
  end

  let(:nonexistent_group) do
    "foobar"
  end

  # This should return the minimal set of attributes required to create a valid
  # Group. As you add validations to Group, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    { name: "group_name" }
  end

  let(:invalid_attributes) do
    { name: "" }
  end

  before do
    login_as current_user
  end

  describe "GET /index" do
    let!(:trial_groups) do
      create_list :group, 3, organisation: editor_user.organisation, status: :trial do |group|
        create :membership, user: editor_user, group:
      end
    end
    let!(:non_member_trial_groups) do
      create_list :group, 2, organisation: editor_user.organisation, status: :trial
    end
    let!(:upgrade_requested_groups) do
      create_list :group, 3, organisation: editor_user.organisation, status: :upgrade_requested do |group|
        create :membership, user: editor_user, group:
      end
    end
    let!(:active_groups) do
      create_list :group, 3, organisation: editor_user.organisation, status: :active do |group|
        create :membership, user: editor_user, group:
      end
    end

    let(:other_org) { create :organisation, id: 2, slug: "other-org" }
    let!(:other_org_trial_groups) { create_list :group, 3, organisation: other_org, status: :trial }

    context "when the user is not a super-admin" do
      before do
        get groups_url
      end

      it "renders a successful response" do
        expect(response).to be_successful
      end

      it "shows all trial groups the user is a member of" do
        expect(assigns(:trial_groups)).to match_array(trial_groups)
      end

      it "shows all upgrade requested groups the user is a member of" do
        expect(assigns(:upgrade_requested_groups)).to match_array(upgrade_requested_groups)
      end

      it "shows all active groups the user is a member of" do
        expect(assigns(:active_groups)).to match_array(active_groups)
      end

      context "with an organisation search query" do
        it "ignores the search query and displays the user's groups" do
          get groups_url, params: { search: { organisation_id: other_org.id } }
          expect(assigns(:trial_groups)).to match_array(trial_groups)
          expect(assigns(:active_groups)).to match_array(active_groups)
          expect(assigns(:upgrade_requested_groups)).to match_array(upgrade_requested_groups)
        end
      end

      context "when the groups feature flag is disabled", feature_groups: false do
        it "returns a 404 response" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the user is a organisation admin of the organisation" do
      before do
        login_as_organisation_admin_user
        get groups_url
      end

      it "shows all trial groups belonging to the organisation" do
        expect(assigns(:trial_groups)).to match_array(trial_groups + non_member_trial_groups)
      end

      it "shows all upgrade requested groups belonging to the organisation" do
        expect(assigns(:upgrade_requested_groups)).to match_array(upgrade_requested_groups)
      end

      it "shows all active groups the user belonging to the organisation" do
        expect(assigns(:active_groups)).to match_array(active_groups)
      end
    end

    context "when the user is a super-admin" do
      before do
        login_as_super_admin_user
      end

      context "with an organisation search query" do
        let!(:other_org_active_groups) { create_list :group, 3, :active, organisation: other_org }
        let!(:other_org_upgrade_requested_groups) { create_list :group, 3, :upgrade_requested, organisation: other_org }

        it "shows groups for organisation in query" do
          get groups_url, params: { search: { organisation_id: other_org.id } }
          expect(assigns(:trial_groups)).to match_array(other_org_trial_groups)
          expect(assigns(:active_groups)).to match_array(other_org_active_groups)
          expect(assigns(:upgrade_requested_groups)).to match_array(other_org_upgrade_requested_groups)
        end
      end

      context "without a search query" do
        it "shows the groups for the user's organisation" do
          get groups_url
          expect(assigns(:trial_groups)).to match_array(trial_groups + non_member_trial_groups)
          expect(assigns(:active_groups)).to match_array(active_groups)
          expect(assigns(:upgrade_requested_groups)).to match_array(upgrade_requested_groups)
        end
      end
    end
  end

  describe "GET /show" do
    context "when the user is a member of the group" do
      it "renders a successful response" do
        get group_url(member_group)
        expect(response).to be_successful
      end

      it "shows the forms in the group" do
        forms = build_list(:form, 3) { |form, i| form.id = i }

        ActiveResource::HttpMock.respond_to do |mock|
          headers = { "X-API-Token" => Settings.forms_api.auth_key, "Accept" => "application/json" }
          forms.each do |form|
            mock.get "/api/v1/forms/#{form.id}", headers, form.to_json, 200
          end
        end

        member_group.group_forms << forms.map { |form| GroupForm.create! form_id: form.id, group_id: member_group.id }
        member_group.save!

        get group_url(member_group)
        expect(assigns[:forms]).to match_array(forms)
      end
    end

    context "when user is not a member of group" do
      it "is forbidden" do
        get group_url(non_member_group)
        expect(response).to have_http_status(:forbidden)
      end

      context "and logged in as a super admin" do
        it "is allowed" do
          login_as_super_admin_user
          get group_url(non_member_group)
          expect(response).to be_successful
        end
      end
    end

    context "when the user is an admin for the organisation" do
      let(:current_user) { organisation_admin_user }

      it "has a link to upgrade the trial group" do
        get group_url(member_group)
        expect(response.body).to include(I18n.t("groups.show.trial_banner.upgrade.link"))
      end
    end

    context "when there is no group with the given ID" do
      it "renders a 404 not found response" do
        get group_url(nonexistent_group)
        expect(response).to have_http_status :not_found
      end
    end

    context "when the groups feature flag is disabled", feature_groups: false do
      it "returns a 404 response" do
        get group_url(member_group)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_group_url
      expect(response).to be_successful
    end

    context "when the groups feature flag is disabled", feature_groups: false do
      it "returns a 404 response" do
        get new_group_url
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /edit" do
    context "when user is a group admin of group" do
      let(:role) { :group_admin }

      it "renders a successful response" do
        get edit_group_url(member_group)
        expect(response).to be_successful
      end
    end

    context "when user is an editor for the group" do
      let(:role) { :editor }

      it "is forbidden" do
        get edit_group_url(non_member_group)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when user is not a member of group" do
      it "is forbidden" do
        get edit_group_url(non_member_group)
        expect(response).to have_http_status(:forbidden)
      end

      context "when logged in as a super admin" do
        it "is allowed" do
          login_as_super_admin_user
          get edit_group_url(non_member_group)
          expect(response).to be_successful
        end
      end
    end

    context "when there is no group with the given ID" do
      it "renders a 404 not found response" do
        get edit_group_url(nonexistent_group)
        expect(response).to have_http_status :not_found
      end
    end

    context "when the groups feature flag is disabled", feature_groups: false do
      it "returns a 404 response" do
        get edit_group_url(non_member_group)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Group" do
        expect {
          post groups_url, params: { group: valid_attributes }
        }.to change(Group, :count).by(1)
      end

      it "redirects to the created group" do
        post groups_url, params: { group: valid_attributes }
        expect(response).to redirect_to(group_url(Group.last))
      end

      it "records the creator" do
        post groups_url, params: { group: valid_attributes }

        expect(Group.last.creator).to eq(current_user)
      end

      it "gives the creator the group admin role" do
        post groups_url, params: { group: valid_attributes }

        expect(Membership.last).to have_attributes user: current_user, role: "group_admin"
      end
    end

    context "with invalid parameters" do
      it "does not create a new Group" do
        expect {
          post groups_url, params: { group: invalid_attributes }
        }.not_to change(Group, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post groups_url, params: { group: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when the groups feature flag is disabled", feature_groups: false do
      it "returns a 404 response" do
        post groups_url, params: { group: valid_attributes }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /update" do
    context "when user is a group admin of group" do
      let(:role) { :group_admin }

      context "with valid parameters" do
        let(:new_attributes) do
          { name: "new_group_name" }
        end

        before do
          patch group_url(member_group), params: { group: new_attributes }
          member_group.reload
        end

        context "when user is a member of group" do
          context "when the group is in trial mode" do
            it "updates the requested group" do
              expect(member_group.name).to eq("new_group_name")
            end

            it "redirects to the group" do
              expect(response).to redirect_to(group_url(member_group))
            end

            it "does not display a success flash message" do
              expect(flash[:success]).to be_nil
            end
          end

          context "when the group is active" do
            let(:member_group) do
              create(:group, :active, organisation: current_user.organisation).tap do |group|
                create(:membership, user: current_user, group:, role:)
              end
            end

            it "updates the requested group" do
              expect(member_group.name).to eq("new_group_name")
            end

            it "redirects to the group" do
              expect(response).to redirect_to(group_url(member_group))
            end

            it "displays a success flash message" do
              expect(flash[:success]).to eq("The name of this group has been changed")
            end
          end
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          patch group_url(member_group), params: { group: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when the user is an editor of the group" do
      let(:role) { :editor }

      it "is forbidden" do
        get edit_group_url(non_member_group)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when user is not a member of the group" do
      it "is forbidden" do
        patch group_url(non_member_group), params: { group: valid_attributes }
        expect(response).to have_http_status(:forbidden)
      end

      context "when logged in as a super admin" do
        it "is allowed" do
          login_as_super_admin_user
          patch group_url(non_member_group), params: { group: valid_attributes }
          expect(response).to be_redirect
        end
      end
    end

    context "when there is no group with the given ID" do
      it "renders a 404 not found response" do
        patch group_url(nonexistent_group), params: { group: valid_attributes }
        expect(response).to have_http_status :not_found
      end
    end

    context "when the groups feature flag is disabled", feature_groups: false do
      it "returns a 404 response" do
        patch group_url(member_group), params: { group: valid_attributes }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /upgrade" do
    before do
      get upgrade_group_url(member_group)
    end

    context "when user is an organisation admin" do
      let(:current_user) { organisation_admin_user }

      it "returns a successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the confirm upgrade view" do
        expect(response).to render_template(:confirm_upgrade)
      end
    end

    context "when user is not an organisation admin" do
      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when there is no group with the given ID" do
      it "renders a 404 not found response" do
        get upgrade_group_url(nonexistent_group)
        expect(response).to have_http_status :not_found
      end
    end

    context "when the groups feature flag is disabled", feature_groups: false do
      it "returns a 404 response" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /upgrade" do
    let(:confirm) { :yes }

    context "when user is an organisation admin" do
      let(:current_user) { organisation_admin_user }

      context "when 'Yes' is selected" do
        it "updates the group to active" do
          expect {
            post upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
          }.to change { member_group.reload.status }.to("active")
        end

        it "redirects to the group" do
          post upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
          expect(response).to redirect_to(group_path(member_group))
        end
      end

      context "when 'No' is selected" do
        let(:confirm) { :no }

        it "does not update the group" do
          expect {
            post upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
          }.not_to(change { member_group.reload.status })
        end

        it "redirects to the group" do
          post upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
          expect(response).to redirect_to(group_path(member_group))
        end
      end

      context "when no option is selected" do
        let(:confirm) { nil }

        before do
          post upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
        end

        it "returns 422" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "re-renders the confirm upgrade page with an error" do
          expect(response).to render_template(:confirm_upgrade)
          expect(response.body).to include("Select yes if you want to upgrade this group")
        end
      end
    end

    context "when user is not an organisation admin" do
      it "is forbidden" do
        post upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when there is no group with the given ID" do
      it "renders a 404 not found response" do
        post upgrade_group_url(nonexistent_group), params: { groups_confirm_upgrade_input: { confirm: } }
        expect(response).to have_http_status :not_found
      end
    end

    context "when the groups feature flag is disabled", feature_groups: false do
      it "returns a 404 response" do
        post upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /request_upgrade" do
    let(:org_has_admin_user) { true }

    before do
      create(:organisation_admin_user, organisation: current_user.organisation) if org_has_admin_user

      get request_upgrade_group_url(member_group)
    end

    context "when user is a group admin" do
      let(:role) { :group_admin }

      it "returns a successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the confirm upgrade request view" do
        expect(response).to render_template(:confirm_upgrade_request)
      end

      context "and their organisation does not have an admin user" do
        let(:org_has_admin_user) { false }

        it "is forbidden" do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context "when the user is not a group admin" do
      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when there is no group with the given ID" do
      let(:member_group) { nonexistent_group }

      it "renders a 404 not found response" do
        expect(response).to have_http_status :not_found
      end
    end

    context "when the groups feature flag is disabled", feature_groups: false do
      it "returns a 404 response" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /request_upgrade" do
    let(:org_has_admin_user) { true }

    before do
      create(:organisation_admin_user, organisation: current_user.organisation) if org_has_admin_user
    end

    context "when user is a group admin" do
      let(:role) { :group_admin }

      it "updates the group status to upgrade_requested" do
        expect {
          post request_upgrade_group_url(member_group)
        }.to change { member_group.reload.status }.to("upgrade_requested")
      end

      it "returns a successful response" do
        post request_upgrade_group_url(member_group)

        expect(response).to have_http_status(:ok)
      end

      it "renders the upgrade requested page" do
        post request_upgrade_group_url(member_group)

        expect(response).to render_template(:upgrade_requested)
      end

      context "when the organisation does not have an admin user" do
        let(:org_has_admin_user) { false }

        it "is forbidden" do
          post request_upgrade_group_url(member_group)

          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context "when the user is not a group admin" do
      let(:role) { :editor }

      it "is forbidden" do
        post request_upgrade_group_url(member_group)

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when there is no group with the given ID" do
      it "renders a 404 not found response" do
        post request_upgrade_group_url(nonexistent_group)
        expect(response).to have_http_status :not_found
      end
    end

    context "when the groups feature flag is disabled", feature_groups: false do
      it "returns a 404 response" do
        post request_upgrade_group_url(member_group)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /review_upgrade" do
    let(:status) { :upgrade_requested }
    let(:upgrade_requester) { create(:user) }

    before do
      get review_upgrade_group_url(member_group)
    end

    context "when user is an organisation admin" do
      let(:current_user) { organisation_admin_user }

      it "returns a successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the review upgrade view" do
        expect(response).to render_template(:review_upgrade)
      end
    end

    context "when user is not an organisation admin" do
      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when there is no group with the given ID" do
      it "renders a 404 not found response" do
        get review_upgrade_group_url(nonexistent_group)
        expect(response).to have_http_status :not_found
      end
    end

    context "when the groups feature flag is disabled", feature_groups: false do
      it "returns a 404 response" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /review_upgrade" do
    let(:status) { :upgrade_requested }
    let(:confirm) { :yes }
    let(:upgrade_requester) { create(:user) }

    context "when user is an organisation admin" do
      let(:current_user) { organisation_admin_user }

      context "when 'Yes' is selected" do
        it "updates the group to active" do
          expect {
            post review_upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
          }.to change { member_group.reload.status }.to("active")
        end

        it "redirects to the group" do
          post review_upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
          expect(response).to redirect_to(group_path(member_group))
        end

        it "returns 303" do
          post review_upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when 'No' is selected" do
        let(:confirm) { :no }

        it "updates the group status to trial" do
          expect {
            post review_upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
          }.to change { member_group.reload.status }.to("trial")
        end

        it "redirects to the group" do
          post review_upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
          expect(response).to redirect_to(group_path(member_group))
        end

        it "returns 303" do
          post review_upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when no option is selected" do
        let(:confirm) { nil }

        before do
          post review_upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
        end

        it "returns 422" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "re-renders the confirm upgrade page with an error" do
          expect(response).to render_template(:review_upgrade)
          expect(response.body).to include("Select yes if you want to upgrade this group")
        end
      end
    end

    context "when user is not an organisation admin" do
      it "is forbidden" do
        post review_upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when there is no group with the given ID" do
      it "renders a 404 not found response" do
        post review_upgrade_group_url(nonexistent_group), params: { groups_confirm_upgrade_input: { confirm: } }
        expect(response).to have_http_status :not_found
      end
    end

    context "when the groups feature flag is disabled", feature_groups: false do
      it "returns a 404 response" do
        post review_upgrade_group_url(member_group), params: { groups_confirm_upgrade_input: { confirm: } }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
