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
      get copy_form_path(id, "draft")
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders copy template" do
      expect(response).to render_template(:confirm)
    end

    describe "#set_back_link" do
      context "when copying a draft form" do
        it "sets the back link to the draft form edit page" do
          get copy_form_path(id, "draft")
          expect(assigns(:back_link)).to eq({ url: form_path(form.id), body: I18n.t("back_link.form_edit") })
        end
      end

      context "when copying a live form" do
        let(:form) { create(:form, :live) }

        it "sets the back link to the live form view page" do
          get copy_form_path(id, "live")
          expect(assigns(:back_link)).to eq({ url: live_form_path(form.id), body: I18n.t("back_link.form_view") })
        end
      end

      context "when copying an archived form" do
        let(:form) { create(:form, :archived) }

        it "sets the back link to the archived form view page" do
          get copy_form_path(id, "archived")
          expect(assigns(:back_link)).to eq({ url: archived_form_path(form.id), body: I18n.t("back_link.form_view") })
        end
      end
    end
  end

  describe "#create" do
    context "when the copy is successful" do
      it "redirects to the form page" do
        post create_copy_form_path(id), params: { forms_copy_input: { name: "Copied Form", tag: "draft" } }

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(form_path(Form.last.id))
      end
    end

    context "when the copy fails" do
      it "renders the confirm template" do
        post create_copy_form_path(id), params: { forms_copy_input: { name: "", tag: "draft" } }

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:confirm)
      end
    end
  end
end
