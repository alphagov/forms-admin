require "rails_helper"

RSpec.describe Forms::BatchSubmissionsController, type: :request do
  let(:form) { create(:form, :live, send_daily_submission_batch:, send_weekly_submission_batch:) }
  let(:send_daily_submission_batch) { false }
  let(:send_weekly_submission_batch) { false }
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
    let(:batch_frequencies) { %w[daily] }
    let(:params) { { forms_batch_submissions_input: { batch_frequencies: } } }

    context "when the weekly submission batch feature is disabled", feature_weekly_submission_emails_enabled: false do
      context "when the daily batch checkbox is checked" do
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

      context "when the daily batch checkbox is not checked" do
        let(:send_daily_submission_batch) { true }
        let(:batch_frequencies) { [] }

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
    end

    context "when the weekly submission batch feature is enabled", :feature_weekly_submission_emails_enabled do
      let(:batch_frequencies) { %w[daily weekly] }

      before do
        post(batch_submissions_create_path(form_id: form.id), params:)
      end

      it "updates the form" do
        expect(form.reload.send_daily_submission_batch).to be true
        expect(form.reload.send_weekly_submission_batch).to be true
      end

      it "redirects to the form overview page" do
        expect(response).to redirect_to(form_path(form.id))
      end

      context "when only the daily batch checkbox is checked" do
        let(:batch_frequencies) { %w[daily] }

        it "displays a success flash message indicating that daily batch emails are enabled" do
          expect(flash[:success]).to eq(I18n.t("banner.success.form.batch_submissions.daily_enabled"))
        end
      end

      context "when only the weekly batch checkbox is checked" do
        let(:batch_frequencies) { %w[weekly] }

        it "displays a success flash message indicating that weekly batch emails are enabled" do
          expect(flash[:success]).to eq(I18n.t("banner.success.form.batch_submissions.weekly_enabled"))
        end
      end

      context "when both the daily and weekly batch checkboxes are checked" do
        let(:batch_frequencies) { %w[daily weekly] }

        it "displays a success flash message indicating that daily and weekly batch emails are enabled" do
          expect(flash[:success]).to eq(I18n.t("banner.success.form.batch_submissions.daily_and_weekly_enabled"))
        end
      end

      context "when daily and weekly batch checkboxes are unchecked" do
        let(:send_daily_submission_batch) { true }
        let(:send_weekly_submission_batch) { true }
        let(:batch_frequencies) { [] }

        it "displays a success flash message indicating that batch emails are disabled" do
          expect(flash[:success]).to eq(I18n.t("banner.success.form.batch_submissions.disabled"))
        end
      end
    end

    context "when the setting is unchanged" do
      let(:send_daily_submission_batch) { true }
      let(:batch_frequencies) { %w[daily] }

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
