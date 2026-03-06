require "rails_helper"

RSpec.describe MouSignaturesController, type: :request do
  before do
    login_as_standard_user
  end

  context "when the URL is for the crown MOU" do
    context "when the user has not signed the memorandum of understanding" do
      describe "#show" do
        it "redirects to the new route" do
          get mou_signature_url
          expect(response).to redirect_to(new_mou_signature_url)
          expect(assigns(:agreement_type)).to eq(:crown)
        end
      end

      describe "#new" do
        it "returns http success" do
          get new_mou_signature_url
          expect(response).to have_http_status(:success)
          expect(assigns(:agreement_type)).to eq(:crown)
        end
      end

      describe "#confirmation" do
        it "redirects to new_mou_signature_url" do
          get confirmation_mou_signature_url
          expect(response).to redirect_to(new_mou_signature_url)
          expect(assigns(:agreement_type)).to eq(:crown)
        end
      end

      describe "#create" do
        let(:params) do
          {
            mou_signature: {
              agreed: "1",
            },
          }
        end

        it "creates an MouSignature" do
          expect { post(mou_signature_url, params:) }
            .to change(MouSignature, :count).by(1)

          mou_signature = MouSignature.last
          expect(mou_signature.user).to eq(standard_user)
          expect(mou_signature.organisation).to eq(standard_user.organisation)
          expect(mou_signature.agreement_type).to eq("crown")
        end

        it "redirects to the confirmation page" do
          post(mou_signature_url, params:)
          expect(response).to redirect_to(confirmation_mou_signature_url)
        end
      end
    end

    context "when the user has already signed the memorandum of understanding" do
      before do
        create(:mou_signature, user: standard_user, organisation: standard_user.organisation, agreement_type: :crown)
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
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when the user has already signed a non-crown agreement" do
      before do
        create(:mou_signature, user: standard_user, organisation: standard_user.organisation, agreement_type: :non_crown)
      end

      describe "#show" do
        it "redirects to the non-crown agreement page" do
          get mou_signature_url
          expect(response).to redirect_to(non_crown_agreement_signature_url)
        end
      end

      describe "#new" do
        it "redirects to the non-crown agreement page" do
          get new_mou_signature_url
          expect(response).to redirect_to(non_crown_agreement_signature_url)
        end
      end
    end
  end

  context "when the URL is for the non-crown agreement" do
    context "when the user has not signed the agreement" do
      describe "#show" do
        it "redirects to the new route" do
          get non_crown_agreement_signature_url
          expect(response).to redirect_to(new_non_crown_agreement_signature_url)
          expect(assigns(:agreement_type)).to eq(:non_crown)
        end
      end

      describe "#new" do
        it "returns http success" do
          get new_non_crown_agreement_signature_url
          expect(response).to have_http_status(:success)
          expect(assigns(:agreement_type)).to eq(:non_crown)
        end
      end

      describe "#confirmation" do
        it "redirects to new path" do
          get confirmation_non_crown_agreement_signature_url
          expect(response).to redirect_to(new_non_crown_agreement_signature_url)
          expect(assigns(:agreement_type)).to eq(:non_crown)
        end
      end

      describe "#create" do
        let(:params) do
          {
            mou_signature: {
              agreed: "1",
            },
          }
        end

        it "creates an MouSignature" do
          expect { post(non_crown_agreement_signature_url, params:) }
            .to change(MouSignature, :count).by(1)

          mou_signature = MouSignature.last
          expect(mou_signature.user).to eq(standard_user)
          expect(mou_signature.organisation).to eq(standard_user.organisation)
          expect(mou_signature.agreement_type).to eq("non_crown")
        end

        it "redirects to the confirmation page" do
          post(non_crown_agreement_signature_url, params:)
          expect(response).to redirect_to(confirmation_non_crown_agreement_signature_url)
        end
      end
    end

    context "when the user has already signed the agreement" do
      before do
        create(:mou_signature, user: standard_user, organisation: standard_user.organisation, agreement_type: :non_crown)
      end

      describe "#show" do
        it "returns http success" do
          get non_crown_agreement_signature_url
          expect(response).to have_http_status(:success)
        end
      end

      describe "#new" do
        it "redirects to the show page" do
          get new_non_crown_agreement_signature_url
          expect(response).to redirect_to(non_crown_agreement_signature_url)
        end
      end

      describe "#confirmation" do
        it "redirects to the show page" do
          get confirmation_non_crown_agreement_signature_url
          expect(response).to have_http_status(:success)
        end
      end

      describe "#create" do
        it "redirects to the show page" do
          post non_crown_agreement_signature_url, params: {
            mou_signature: {
              agreed: "1",
            },
          }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when the user has already signed a crown MOU" do
      before do
        create(:mou_signature, user: standard_user, organisation: standard_user.organisation, agreement_type: :crown)
      end

      describe "#show" do
        it "redirects to the crown MOU page" do
          get non_crown_agreement_signature_url
          expect(response).to redirect_to(mou_signature_url)
        end
      end

      describe "#new" do
        it "redirects to the crown MOU page" do
          get new_non_crown_agreement_signature_url
          expect(response).to redirect_to(mou_signature_url)
        end
      end
    end
  end
end
