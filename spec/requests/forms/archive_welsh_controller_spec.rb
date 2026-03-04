require "rails_helper"

RSpec.describe Forms::ArchiveWelshController, type: :request do
  let(:id) { form.id }
  let(:form) { create(:form, :live, :with_welsh_translation) }
  let(:membership) { Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user) }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    membership
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#show" do
    before do
      get archive_welsh_path(id)
    end

    context "when the form has a live Welsh translation" do
      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders archive Welsh page" do
        expect(response).to render_template(:show)
      end

      context "when form is not live" do
        let(:form) { create(:form, :archived) }

        it "redirects to archived form page" do
          expect(response).to redirect_to(archived_form_path(id))
        end
      end

      context "when the user does not have permission to view the form" do
        let(:membership) { nil }

        it "returns forbidden" do
          expect(response).to have_http_status :forbidden
        end
      end
    end

    context "when form does not have a live Welsh translation" do
      before do
        FormDocument.find_by(form_id: id, language: "cy", tag: "live").destroy!
      end

      it "redirects to live form page" do
        get archive_welsh_path(id)
        expect(response).to redirect_to(live_form_path(id))
      end
    end
  end

  describe "#update" do
    let(:confirm) { :yes }

    context "when 'Yes' is selected" do
      it "archives the Welsh form" do
        expect {
          post archive_welsh_update_path(id), params: { forms_confirm_archive_welsh_input: { confirm:, form: } }
        }.to change { FormDocument.find_by(form_id: id, language: "cy", tag: "live").present? }.from(true).to(false)
      end

      it "redirects to the live form page" do
        post archive_welsh_update_path(id), params: { forms_confirm_archive_welsh_input: { confirm:, form: } }
        expect(response).to redirect_to(live_form_path(form.id))
      end
    end

    context "when 'No' is selected" do
      let(:confirm) { :no }

      it "redirects to live form page" do
        post archive_welsh_update_path(id), params: { forms_confirm_archive_welsh_input: { confirm:, form: } }
        expect(response).to redirect_to(live_form_path(id))
      end
    end

    context "when no option is selected" do
      let(:confirm) { nil }

      before do
        post archive_welsh_update_path(id), params: { forms_confirm_archive_welsh_input: { confirm:, form: } }
      end

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "re-renders the show template with an error" do
        expect(response).to render_template(:show)
        expect(response.body).to include("Select ‘Yes’ if you want to archive the Welsh version of this form")
      end
    end

    context "when form is not live" do
      let(:form) { create(:form, :archived) }

      it "doesn't archive the form" do
        expect {
          post archive_welsh_update_path(id), params: { forms_confirm_archive_welsh_input: { confirm:, form: } }
        }.not_to change(form, :state)
      end

      it "redirects to archived form page" do
        post archive_welsh_update_path(id), params: { forms_confirm_archive_welsh_input: { confirm:, form: } }
        expect(response).to redirect_to(archived_form_path(id))
      end
    end
  end
end
