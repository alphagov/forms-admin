require "rails_helper"

RSpec.describe Forms::DeleteConfirmationController, type: :request do
  let(:form) { build(:form, id: 2) }
  let(:page) { build(:page, form_id: form.id) }

  let(:group) { create(:group, organisation: standard_user.organisation) }
  let(:membership) { create :membership, group:, user: standard_user }

  before do
    membership
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#delete" do
    describe "Given a valid form" do
      before do
        allow(FormRepository).to receive(:find).and_return(form)

        get delete_form_path(form_id: 2)
      end

      it "reads the form from the API" do
        expect(FormRepository).to have_received(:find)
      end

      context "when current user is not in group for form" do
        let(:membership) { nil }

        it "returns an error" do
          expect(response).to have_http_status :forbidden
        end
      end
    end
  end

  describe "#destroy" do
    describe "Given a valid form" do
      let(:form) { build(:form, id: 2, name: "Form 1") }

      before do
        allow(FormRepository).to receive_messages(find: form, destroy: true)

        delete destroy_form_path(form_id: 2, forms_delete_confirmation_input: { confirm: "yes" })
      end

      it "redirects you to the group page" do
        expect(response).to redirect_to(group_path(group))
      end

      it "deletes the form" do
        expect(FormRepository).to have_received(:destroy)
      end

      it "displays a success flash message" do
        expect(flash[:success]).to eq "Successfully deleted ‘Form 1’"
      end

      context "when current user is not in group for form" do
        let(:membership) { nil }

        it "returns an error" do
          expect(response).to have_http_status :forbidden
        end

        it "does not delete the form on the API" do
          expect(FormRepository).not_to have_received(:destroy)
        end
      end
    end

    context "when the user has decided not to delete the form" do
      before do
        allow(FormRepository).to receive_messages(find: form, destroy: true)

        delete destroy_form_path(form_id: 2, forms_delete_confirmation_input: { confirm: "no" })
      end

      it "redirects you to the form page" do
        expect(response).to redirect_to(form_path(2))
      end

      it "does not delete the form on the API" do
        expect(FormRepository).not_to have_received(:destroy)
      end
    end

    context "when user has not confirmed whether they want to delete the form or not" do
      before do
        allow(FormRepository).to receive_messages(find: form, destroy: true)

        delete destroy_form_path(form_id: 2, forms_delete_confirmation_input: { confirm: nil })
      end

      it "re-renders the confirm delete view with an error" do
        expect(response).to render_template(:delete)
        expect(response.body).to include "Select ‘Yes’ to delete the draft"
      end

      it "does not delete the form on the API" do
        expect(FormRepository).not_to have_received(:destroy)
      end
    end
  end
end
