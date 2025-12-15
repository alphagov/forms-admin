require "rails_helper"

RSpec.describe Forms::CopyController, type: :request do
  let(:id) { form.id }
  let(:form) { create(:form) }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#copy" do
    before do
      get copy_form_path(id)
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders copy template" do
      expect(response).to render_template(:confirm)
    end
  end

  describe "#create" do
    context "when the copy is successful" do
      it "redirects to the form page" do
        post copy_form_path(id), params: { forms_copy_input: { name: "Copied Form", tag: "draft" } }

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(form_path(Form.last.id))
      end
    end

    context "when the copy fails" do
      it "renders the confirm template" do
        post copy_form_path(id), params: { forms_copy_input: { name: "", tag: "draft" } }

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:confirm)
      end
    end
  end
end
