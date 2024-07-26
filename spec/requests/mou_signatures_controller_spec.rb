require "rails_helper"

RSpec.describe MouSignaturesController, type: :request do
  before do
    login_as_standard_user
  end

  context "when the user has not signed the memorandum of understanding" do
    describe "#show" do
      it "redirects to the new route" do
        get mou_signature_url
        expect(response).to redirect_to(new_mou_signature_url)
      end
    end

    describe "#new" do
      it "returns http success" do
        get new_mou_signature_url
        expect(response).to have_http_status(:success)
      end
    end

    describe "#confirmation" do
      it "redirects to new_mou_signature_url" do
        get confirmation_mou_signature_url
        expect(response).to redirect_to(new_mou_signature_url)
      end
    end

    describe "#create" do
      it "redirects to the confirmation page" do
        post mou_signature_url, params: {
          mou_signature: {
            agreed: "1",
          },
        }
        expect(response).to redirect_to(confirmation_mou_signature_url)
      end
    end
  end

  context "when the user has already signed the memorandum of understanding" do
    before do
      create(:mou_signature, user: standard_user, organisation: standard_user.organisation)
    end

    describe "#show" do
      it "returns http success" do
        get mou_signature_url
        expect(response).to have_http_status(:success)
      end
    end

    describe "#new" do
      it "redirects to the show page" do
        get new_mou_signature_url
        expect(response).to redirect_to(mou_signature_url)
      end
    end

    describe "#confirmation" do
      it "redirects to the show page" do
        get confirmation_mou_signature_url
        expect(response).to have_http_status(:success)
      end
    end

    describe "#create" do
      it "redirects to the show page" do
        post mou_signature_url, params: {
          mou_signature: {
            agreed: "1",
          },
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
