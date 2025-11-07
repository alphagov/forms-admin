require "rails_helper"

RSpec.describe Forms::WelshTranslationController, type: :request do
  let(:form) { create(:form, :with_pages, welsh_completed: false) }
  let(:id) { form.id }

  let(:current_user) { standard_user }
  let(:group) { create(:group, organisation: standard_user.organisation, welsh_enabled:) }

  let(:welsh_enabled) { true }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)

    login_as current_user
  end

  describe "#new" do
    before do
      get welsh_translation_path(id)
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the template" do
      expect(response).to render_template(:new)
    end

    context "when the user is not authorized" do
      let(:current_user) { build :user }

      it "returns 403" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when the welsh feature is not enabled for the group" do
      let(:welsh_enabled) { false }

      it "redirects to the form" do
        expect(response).to redirect_to(form_path(id))
      end
    end
  end

  describe "#create" do
    let(:mark_complete) { "true" }
    let(:page_translations) { { "0" => { "id" => form.pages.first.id, question_text_cy: "Ydych chi'n adnewyddu trwydded?" } } }
    let(:params) { { forms_welsh_translation_input: { form:, mark_complete:, page_translations: } } }

    context "when 'Yes' is selected" do
      it "updates the form" do
        expect {
          post(welsh_translation_create_path(id), params:)
        }.to change { form.reload.welsh_completed }.to(true)
      end

      it "updates the form's pages" do
        expect {
          post(welsh_translation_create_path(id), params:)
        }.to change { form.pages.first.reload.question_text_cy }.to("Ydych chi'n adnewyddu trwydded?")
      end

      it "redirects to the form" do
        post(welsh_translation_create_path(id), params:)
        expect(response).to redirect_to(form_path(id))
      end

      it "displays a success banner including text about being marked complete" do
        post(welsh_translation_create_path(id), params:)
        expect(flash[:success]).to eq(I18n.t("banner.success.form.welsh_translation_saved_and_completed"))
      end
    end

    context "when 'No' is selected" do
      let(:mark_complete) { "false" }
      let(:form) { create(:form, :with_pages, welsh_completed: true) }

      it "updates the form" do
        expect {
          post(welsh_translation_create_path(id), params:)
        }.to change { form.reload.welsh_completed }.to(false)
      end

      it "redirects to the form" do
        post(welsh_translation_create_path(id), params:)
        expect(response).to redirect_to(form_path(id))
      end

      it "displays a success banner without text about being marked complete" do
        post(welsh_translation_create_path(id), params:)
        expect(flash[:success]).to eq(I18n.t("banner.success.form.welsh_translation_saved"))
      end
    end

    context "when no value is selected" do
      let(:mark_complete) { "" }

      it "does not update the form" do
        expect {
          post(welsh_translation_create_path(id), params:)
        }.not_to(change { form.reload.welsh_completed })
      end

      it "does not update the form's pages" do
        expect {
          post(welsh_translation_create_path(id), params:)
        }.not_to(change { form.pages.first.reload.question_text_cy })
      end

      it "returns a 422" do
        post(welsh_translation_create_path(id), params:)
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "re-renders the page with an error" do
        post(welsh_translation_create_path(id), params:)
        expect(response).to render_template(:new)
        expect(response.body).to include(I18n.t("activemodel.errors.models.forms/welsh_translation_input.attributes.mark_complete.blank"))
      end

      it "does not display a success banner" do
        post(welsh_translation_create_path(id), params:)
        expect(flash).to be_empty
      end
    end

    context "when the user is not authorized" do
      let(:current_user) { build :user }

      it "does not update the form" do
        expect {
          post(welsh_translation_create_path(id), params:)
        }.not_to(change { form.reload.welsh_completed })
      end

      it "does not update the form's pages" do
        expect {
          post(welsh_translation_create_path(id), params:)
        }.not_to(change { form.pages.first.reload.question_text_cy })
      end

      it "returns 403" do
        post(welsh_translation_create_path(id), params:)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when the welsh feature is not enabled for the group" do
      let(:welsh_enabled) { false }

      it "does not update the form" do
        expect {
          post(welsh_translation_create_path(id), params:)
        }.not_to(change { form.reload.welsh_completed })
      end

      it "does not update the form's pages" do
        expect {
          post(welsh_translation_create_path(id), params:)
        }.not_to(change { form.pages.first.reload.question_text_cy })
      end

      it "redirects to the form" do
        post(welsh_translation_create_path(id), params:)
        expect(response).to redirect_to(form_path(id))
      end
    end
  end
end
