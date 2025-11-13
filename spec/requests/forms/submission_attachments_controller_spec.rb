require "rails_helper"

RSpec.describe Forms::SubmissionAttachmentsController, type: :request do
  let(:form) { create(:form, :live, submission_format: original_submission_format) }
  let(:original_submission_format) { [] }

  before do
    login_as_super_admin_user
  end

  describe "#new" do
    context "when the json_submission_enabled feature flag is off" do
      before do
        allow(Settings.features).to receive(:json_submission_enabled).and_return(false)

        get submission_attachments_path(form_id: form.id)
      end

      it "returns a 404 page" do
        expect(response).to redirect_to :error_404
      end
    end

    context "when the json_submission_enabled feature flag is on" do
      before do
        allow(Settings.features).to receive(:json_submission_enabled).and_return(true)

        get submission_attachments_path(form_id: form.id)
      end

      it "renders the submission attachments view" do
        expect(response).to have_rendered :new
      end

      it "uses the form submission attachments input" do
        expect(assigns).to include submission_attachments_input: an_instance_of(Forms::SubmissionAttachmentsInput)
      end
    end
  end

  describe "#create" do
    let(:params) { { forms_submission_attachments_input: { submission_format: } } }

    context "when the json_submission_enabled feature flag is off" do
      before do
        allow(Settings.features).to receive(:json_submission_enabled).and_return(false)
      end

      it "returns a 404 page" do
        post submission_attachments_path(form_id: form.id)
        expect(response).to redirect_to :error_404
      end
    end

    context "when the json_submission_enabled feature flag is on" do
      before do
        allow(Settings.features).to receive(:json_submission_enabled).and_return(true)
      end

      context "when params are valid" do
        let(:submission_format) { %w[csv json] }

        it "updates the form submission format" do
          expect {
            post(submission_attachments_path(form_id: form.id), params:)
          }.to change { form.reload.submission_format }.to(submission_format)
        end

        it "redirects you to the form overview page" do
          post(submission_attachments_path(form_id: form.id), params:)
          expect(response).to redirect_to(form_path(form.id))
        end

        context "when submission format has changed to 'csv'" do
          let(:submission_format) { %w[csv] }

          it "displays a success flash message" do
            post(submission_attachments_path(form_id: form.id), params:)
            expect(flash[:success]).to eq(I18n.t("banner.success.form.receive_csv_enabled"))
          end
        end

        context "when submission format has changed to 'json'" do
          let(:submission_format) { %w[json] }

          it "displays a success flash message" do
            post(submission_attachments_path(form_id: form.id), params:)
            expect(flash[:success]).to eq(I18n.t("banner.success.form.receive_json_enabled"))
          end
        end

        context "when submission format has changed to 'csv json'" do
          let(:submission_format) { %w[csv json] }

          it "displays a success flash message" do
            post(submission_attachments_path(form_id: form.id), params:)
            expect(flash[:success]).to eq(I18n.t("banner.success.form.receive_csv_and_json_enabled"))
          end
        end

        context "when submission format has changed to blank" do
          let(:original_submission_format) { %w[csv json] }
          let(:submission_format) { %w[] }

          it "displays a success flash message" do
            post(submission_attachments_path(form_id: form.id), params:)
            expect(flash[:success]).to eq(I18n.t("banner.success.form.receive_no_attachments"))
          end
        end

        context "when submission format has not changed" do
          let(:submission_format) { %w[] }

          it "does not display a flash message" do
            post(submission_attachments_path(form_id: form.id), params:)
            expect(flash[:success]).to be_nil
          end
        end
      end

      context "when params are invalid" do
        let(:submission_format) { %w[apple] }

        it "returns 422" do
          post(submission_attachments_path(form_id: form.id), params:)
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "does not update the form" do
          expect {
            post(submission_attachments_path(form_id: form.id), params:)
          }.not_to(change { form.reload.submission_format })
        end

        it "re-renders the page with an error" do
          post(submission_attachments_path(form_id: form.id), params:)
          expect(response).to render_template("new")
          expect(response.body).to include(I18n.t("activemodel.errors.models.forms/submission_attachments_input.invalid_submission_format"))
        end
      end
    end
  end
end
