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

      it "assigns a new NameForm to @name_form" do
        get edit_account_name_path
        expect(assigns(:name_form)).to be_a(Account::NameForm)
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
      let(:valid_params) { { account_name_form: { name: "John Doe" } } }

      it "updates the user's name" do
        put account_name_path, params: valid_params
        expect(user.reload.name).to eq("John Doe")
      end

      it "redirects to the root path" do
        put account_name_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { account_name_form: { name: "" } } }

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
