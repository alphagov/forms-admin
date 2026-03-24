require "rails_helper"

RSpec.describe Forms::BatchSubmissionsController, type: :request do
  let(:form) { create(:form, :live, send_daily_submission_batch: send_daily_submission_batch_original_value) }
  let(:send_daily_submission_batch_original_value) { false }
  let(:current_user) { standard_user }
  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)

    login_as current_user
  end

  describe "#new" do
    before do
      get batch_submissions_path(form_id: form.id)
    end

    it "renders the daily submission batch view" do
      expect(response).to have_rendered :new
    end

    it "uses the daily submission batch input" do
      expect(assigns).to include batch_submissions_input: an_instance_of(Forms::BatchSubmissionsInput)
    end

    context "when the user is not authorized" do
      let(:current_user) { build :user }

      it "returns 403" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#create" do
    let(:send_batch_submissions_input_value) { "1" }
    let(:params) { { forms_batch_submissions_input: { send_daily_submission_batch: send_batch_submissions_input_value } } }

    context "when the checkbox is checked" do
      let(:send_batch_submissions_input_value) { "1" }

      it "updates the form send_daily_submission_batch flag to true" do
        expect {
          post(batch_submissions_create_path(form_id: form.id), params:)
        }.to change { form.reload.send_daily_submission_batch }.to(true)
      end

      it "redirects to the form overview page" do
        post(batch_submissions_create_path(form_id: form.id), params:)
        expect(response).to redirect_to(form_path(form.id))
      end

      it "displays a success flash message" do
        post(batch_submissions_create_path(form_id: form.id), params:)
        expect(flash[:success]).to eq(I18n.t("banner.success.form.daily_submission_batch_enabled"))
      end
    end

    context "when the checkbox is not checked" do
      let(:send_daily_submission_batch_original_value) { true }
      let(:send_batch_submissions_input_value) { "0" }

      it "updates the form send_daily_submission_batch flag to false" do
        expect {
          post(batch_submissions_create_path(form_id: form.id), params:)
        }.to change { form.reload.send_daily_submission_batch }.to(false)
      end

      it "displays a success flash message" do
        post(batch_submissions_create_path(form_id: form.id), params:)
        expect(flash[:success]).to eq(I18n.t("banner.success.form.daily_submission_batch_disabled"))
      end
    end

    context "when the setting is unchanged" do
      let(:send_daily_submission_batch_original_value) { true }
      let(:send_batch_submissions_input_value) { "1" }

      it "does not display a flash message" do
        post(batch_submissions_create_path(form_id: form.id), params:)
        expect(flash[:success]).to be_nil
      end
    end

    context "when the user is not authorized" do
      let(:current_user) { build :user }

      it "returns 403" do
        post(batch_submissions_create_path(form_id: form.id), params:)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
