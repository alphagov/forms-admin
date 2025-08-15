require "rails_helper"

describe Account::OrganisationsController do
  let(:user) { create(:user, :with_no_org) }

  before do
    login_as user
  end

  describe "GET #edit" do
    context "when the user does not have an organisation" do
      it "renders the edit template" do
        get edit_account_organisation_path
        expect(response).to render_template(:edit)
      end

      it "assigns a new OrganisationForm to @organisation_input" do
        get edit_account_organisation_path
        expect(assigns(:organisation_input)).to be_a(Account::OrganisationInput)
      end
    end

    context "when the user already has an organisation" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get edit_account_organisation_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PUT #update" do
    context "with valid parameters" do
      let(:organisation) { create(:organisation) }
      let(:valid_params) { { account_organisation_input: { organisation_id: organisation.id } } }
      let(:default_group_service) { instance_spy(DefaultGroupService) }

      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(AfterSignInPathHelper).to receive(:after_sign_in_next_path).and_return("/next-path")
        # rubocop:enable RSpec/AnyInstance
        allow(DefaultGroupService).to receive(:new).and_return(default_group_service)
      end

      it "updates the user's organisation" do
        put account_organisation_path, params: valid_params
        expect(user.reload.organisation).to eq(organisation)
      end

      it "redirects to the root path" do
        put account_organisation_path, params: valid_params
        expect(response).to redirect_to("/next-path")
      end

      it "calls create_user_default_trial_group!" do
        put account_organisation_path, params: valid_params
        expect(default_group_service).to have_received(:create_user_default_trial_group!)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { account_organisation_input: { organisation_id: nil } } }

      it "does not update the user's organisation" do
        expect {
          put account_organisation_path, params: invalid_params
        }.not_to(change { user.reload.organisation })
      end

      it "re-renders the edit template" do
        put account_organisation_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template(:edit)
      end
    end
  end
end
