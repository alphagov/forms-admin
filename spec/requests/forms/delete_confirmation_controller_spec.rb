require "rails_helper"

RSpec.describe Forms::DeleteConfirmationController, type: :request do
  let(:form) { build(:form, :with_active_resource, id: 2) }

  let(:group) { create(:group, organisation: editor_user.organisation) }
  let(:membership) { create :membership, group:, user: editor_user }

  before do
    membership
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_editor_user
  end

  describe "#delete" do
    describe "Given a valid form" do
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
        end

        get delete_form_path(form_id: 2)
      end

      it "reads the form from the API" do
        expect(form).to have_been_read
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
      before do
        ActiveResourceMock.mock_resource(form,
                                         {
                                           read: { response: form, status: 200 },
                                           delete: { response: {}, status: 200 },
                                         })

        delete destroy_form_path(form_id: 2, forms_delete_confirmation_input: { confirm: "yes" })
      end

      it "redirects you to the group page" do
        expect(response).to redirect_to(group_path(group))
      end

      it "deletes the form on the API" do
        expect(form).to have_been_deleted
      end

      context "when current user is not in group for form" do
        let(:membership) { nil }

        it "returns an error" do
          expect(response).to have_http_status :forbidden
        end

        it "does not delete the form on the API" do
          expect(form).not_to have_been_deleted
        end
      end
    end

    context "when the user has decided not to delete the form" do
      before do
        ActiveResourceMock.mock_resource(form,
                                         {
                                           read: { response: form, status: 200 },
                                           delete: { response: {}, status: 200 },
                                         })

        delete destroy_form_path(form_id: 2, forms_delete_confirmation_input: { confirm: "no" })
      end

      it "redirects you to the form page" do
        expect(response).to redirect_to(form_path(2))
      end

      it "does not delete the form on the API" do
        expect(form).not_to have_been_deleted
      end
    end
  end
end
