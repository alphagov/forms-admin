require "rails_helper"

RSpec.describe Forms::UnarchiveController, type: :request do
  let(:user) { standard_user }

  let(:form) do
    build(:form,
          :archived,
          id: 2)
  end

  let(:updated_form) do
    build(:form,
          :live,
          id: 2,
          name: form.name,
          form_slug: form.form_slug,
          submission_email: form.submission_email,
          privacy_policy_url: form.privacy_policy_url,
          support_email: form.support_email,
          pages: form.pages)
  end

  let(:group) { create(:group, organisation: user.organisation, status: :active) }
  let(:form_params) { nil }

  describe "#new" do
    before do
      allow(FormRepository).to receive_messages(find: form, save!: updated_form)

      Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user, role: :group_admin)
      GroupForm.create!(form_id: form.id, group_id: group.id)

      login_as user

      get unarchive_path(form_id: 2)
    end

    it "reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the confirmation page" do
      expect(response).to render_template("unarchive_form")
    end

    context "when current user does not belong to the forms group" do
      let(:user) { build :user }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#create" do
    before do
      allow(FormRepository).to receive_messages(find: form, make_live!: form, find_live: form)

      Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user, role: :group_admin)
      GroupForm.create!(form_id: form.id, group_id: group.id)

      login_as user

      post(unarchive_create_path(form_id: 2), params: form_params)
    end

    context "when making a form live again" do
      let(:form_params) { { forms_make_live_input: { confirm: :yes, form: } } }

      it "reads the form" do
        expect(FormRepository).to have_received(:find)
      end

      it "makes form live" do
        expect(FormRepository).to have_received(:make_live!)
      end

      it "renders the confirmation page" do
        expect(response).to render_template("forms/make_live/confirmation")
      end

      it "has the page title 'Your form is live'" do
        expect(response.body).to include "Your form is live"
      end
    end

    context "when deciding not to make a form live again" do
      let(:form_params) { { forms_make_live_input: { confirm: :no } } }

      it "reads the form" do
        expect(FormRepository).to have_received(:find)
      end

      it "does not make the form live" do
        expect(FormRepository).not_to have_received(:make_live!)
      end

      it "redirects you to the archived form page" do
        expect(response).to redirect_to(archived_form_path(2))
      end
    end

    context "when no option is selected" do
      let(:form_params) { { forms_make_live_input: { confirm: :"" } } }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not make the form live" do
        expect(FormRepository).not_to have_received(:make_live!)
      end

      it "re-renders the page with an error" do
        expect(response).to render_template("unarchive_form")
        expect(response.body).to include("You must choose an option")
      end
    end

    context "when current user does not belong to the forms group" do
      let(:user) { build :user }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
