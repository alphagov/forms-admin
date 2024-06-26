require "rails_helper"

RSpec.describe Forms::DeleteConfirmationController, type: :request do
  let(:form) { build(:form, :with_active_resource, id: 2) }

  before do
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
    end
  end

  describe "#destroy" do
    describe "Given a valid form" do
      let(:group) { create :group, organisation_id: editor_user.organisation_id }

      before do
        ActiveResourceMock.mock_resource(form,
                                         {
                                           read: { response: form, status: 200 },
                                           delete: { response: {}, status: 200 },
                                         })
        GroupForm.create!(group:, form_id: form.id) if group.present?

        if group.present?
          create(:membership, user: editor_user, group:)
        end

        delete destroy_form_path(form_id: 2, forms_delete_confirmation_input: { confirm: "yes" })
      end

      it "redirects you to the group page" do
        expect(response).to redirect_to(group_path(group))
      end

      it "deletes the form on the API" do
        expect(form).to have_been_deleted
      end

      context "when the form is not in a group" do
        let(:group) { nil }

        it "redirects to the home page" do
          expect(response).to redirect_to(root_path)
        end
      end

      context "when the groups feature is not enabled", feature_groups: false do
        it "redirects to the home page" do
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
