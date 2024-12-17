require "rails_helper"

RSpec.describe Forms::ArchiveFormController, type: :request do
  let(:id) { 2 }
  let(:form) { build(:form, :live, id:) }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#archive" do
    before do
      allow(FormRepository).to receive(:find).and_return(form)

      get archive_form_path(id)
    end

    it "reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders archive this form page" do
      expect(response).to render_template(:archive)
    end

    context "when form is not live" do
      let(:form) { build(:form, :archived, id:) }

      it "redirects to archived form page" do
        expect(response).to redirect_to(archived_form_path(id))
      end
    end
  end

  describe "#update" do
    let(:confirm) { :yes }

    before do
      allow(FormRepository).to receive_messages(find: form, archive!: form)

      post archive_form_update_path(id), params: { forms_confirm_archive_input: { confirm:, form: } }
    end

    context "when 'Yes' is selected" do
      it "archives the form" do
        expect(FormRepository).to have_received(:archive!)
      end

      it "redirects to the success page" do
        expect(response).to redirect_to(archive_form_confirmation_path(id))
      end
    end

    context "when 'No' is selected" do
      let(:confirm) { :no }

      it "redirects to live form page" do
        expect(response).to redirect_to(live_form_path(id))
      end
    end

    context "when no option is selected" do
      let(:confirm) { nil }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "re-renders the archive this form page with an error" do
        expect(response).to render_template(:archive)
        expect(response.body).to include("Select yes if you want to archive this form")
      end
    end

    context "when form is not live" do
      let(:form) { build(:form, :archived, id:) }

      it "doesn't archive the form" do
        expect(FormRepository).not_to have_received(:archive!)
      end

      it "redirects to archived form page" do
        expect(response).to redirect_to(archived_form_path(id))
      end
    end
  end

  describe "#confirmation" do
    before do
      allow(FormRepository).to receive(:find).and_return(form)

      get archive_form_confirmation_path(id)
    end

    it "renders the success template" do
      expect(response).to render_template(:confirmation)
    end
  end
end
