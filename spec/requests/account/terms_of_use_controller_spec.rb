require "rails_helper"

describe Account::TermsOfUseController do
  let(:user) { create(:user, terms_agreed_at: nil) }

  before do
    login_as user
  end

  describe "GET #edit" do
    context "when user does has not agreed to the terms of use" do
      it "renders the edit template" do
        get edit_account_terms_of_use_path
        expect(response).to render_template(:edit)
      end

      it "assigns a new TermsOfUseInput to @terms_of_use_input" do
        get edit_account_terms_of_use_path
        expect(assigns(:terms_of_use_input)).to be_a(Account::TermsOfUseInput)
      end
    end

    context "when the user has already agreed to the terms of use" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get edit_account_terms_of_use_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:valid_params) { { account_terms_of_use_input: { agreed: "1" } } }
      let(:current_time) { Time.zone.now.midnight }

      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(AfterSignInPathHelper).to receive(:after_sign_in_next_path).and_return("/next-path")
        # rubocop:enable RSpec/AnyInstance

        travel_to current_time
      end

      it "updates the user's terms agreed at timestamp" do
        put account_terms_of_use_path, params: valid_params
        expect(user.reload.terms_agreed_at).to eq(current_time)
      end

      it "redirects to the root path" do
        put account_terms_of_use_path, params: valid_params
        expect(response).to redirect_to("/next-path")
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { account_terms_of_use_input: { agreed: "0" } } }

      it "does not update the user's name" do
        put account_terms_of_use_path, params: invalid_params
        expect(user.reload.terms_agreed_at).to be_nil
      end

      it "renders the edit template" do
        put account_terms_of_use_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end
    end
  end
end
