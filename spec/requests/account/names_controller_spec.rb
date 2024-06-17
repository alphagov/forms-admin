require "rails_helper"

describe Account::NamesController do
  let(:user) { create(:user, name: nil) }

  before do
    login_as user
  end

  describe "GET #edit" do
    context "when user does not have a name" do
      it "renders the edit template" do
        get edit_account_name_path
        expect(response).to render_template(:edit)
      end

      it "assigns a new NameInput to @name_input" do
        get edit_account_name_path
        expect(assigns(:name_input)).to be_a(Account::NameInput)
      end
    end

    context "when the user already has a name" do
      let(:user) { create(:user, name: "John Smith") }

      it "redirects to the root path" do
        get edit_account_name_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:valid_params) { { account_name_input: { name: "John Doe" } } }
      let(:default_group_service) { instance_spy(DefaultGroupService) }

      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(AfterSignInPathHelper).to receive(:after_sign_in_next_path).and_return("/next-path")
        # rubocop:enable RSpec/AnyInstance
        allow(DefaultGroupService).to receive(:new).and_return(default_group_service)
      end

      it "updates the user's name" do
        put account_name_path, params: valid_params
        expect(user.reload.name).to eq("John Doe")
      end

      it "redirects to the root path" do
        put account_name_path, params: valid_params
        expect(response).to redirect_to("/next-path")
      end

      it "calls create_trial_user_default_group!" do
        put account_name_path, params: valid_params
        expect(default_group_service).to have_received(:create_trial_user_default_group!)
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { account_name_input: { name: "" } } }

      it "does not update the user's name" do
        put account_name_path, params: invalid_params
        expect(user.reload.name).to be_nil
      end

      it "renders the edit template" do
        put account_name_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end
    end
  end
end
