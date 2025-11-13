require "rails_helper"

RSpec.describe Forms::ReceiveCsvController, type: :request do
  let(:form) { create(:form, :live, submission_type: original_submission_type, submission_format: original_submission_format) }

  let(:original_submission_type) { "email" }
  let(:original_submission_format) { [] }

  let(:submission_type) { nil }

  before do
    login_as_super_admin_user
  end

  describe "#new" do
    before do
      get receive_csv_path(form_id: form.id)
    end

    it "renders the receive csv view" do
      expect(response).to have_rendered :new
    end

    it "uses the form submission type input" do
      expect(assigns).to include submission_type_input: an_instance_of(Forms::SubmissionTypeInput)
    end

    describe "submission type checkbox" do
      subject(:submission_type_checkbox) { page.find_field("forms_submission_type_input[submission_type]") }

      let(:page) { Capybara.string(response.body) }

      context "when the form has email only submissions" do
        let(:original_submission_type) { "email" }
        let(:original_submission_format) { [] }

        it { is_expected.not_to be_checked }
      end

      context "when the form has email with csv submissions" do
        let(:original_submission_type) { "email_with_csv" }
        let(:original_submission_format) { %w[csv] }

        it { is_expected.to be_checked }
      end
    end
  end

  describe "#create" do
    let(:params) { { forms_submission_type_input: { submission_type: } } }

    context "when params are valid" do
      let(:submission_type) { "email_with_csv" }
      let(:original_submission_format) { [] }

      it "updates the form submission format" do
        expect {
          post(receive_csv_path(form_id: form.id), params:)
        }.to change { form.reload.submission_format }.to(%w[csv])
      end

      it "redirects you to the form overview page" do
        post(receive_csv_path(form_id: form.id), params:)
        expect(response).to redirect_to(form_path(form.id))
      end

      context "when submissions have changed from email only to email with csv" do
        let(:original_submission_type) { "email" }
        let(:original_submission_format) { [] }
        let(:submission_type) { "email_with_csv" }

        it "displays a success flash message" do
          post(receive_csv_path(form_id: form.id), params:)
          expect(flash[:success]).to eq(I18n.t("banner.success.form.receive_csv_enabled"))
        end
      end

      context "when submissions have changed from email with csv to email only" do
        let(:original_submission_type) { "email_with_csv" }
        let(:original_submission_format) { %w[csv] }
        let(:submission_type) { "email" }

        it "displays a success flash message" do
          post(receive_csv_path(form_id: form.id), params:)
          expect(flash[:success]).to eq(I18n.t("banner.success.form.receive_csv_disabled"))
        end
      end

      context "when submissions have not changed from email only" do
        let(:original_submission_type) { "email" }
        let(:original_submission_format) { [] }
        let(:submission_type) { "email" }

        it "does not display a success flash message" do
          post(receive_csv_path(form_id: form.id), params:)
          expect(flash[:success]).to be_nil
        end
      end

      context "when submissions have not changed from email with csv" do
        let(:original_submission_type) { "email_with_csv" }
        let(:original_submission_format) { %w[csv] }
        let(:submission_type) { "email_with_csv" }

        it "does not display a success flash message" do
          post(receive_csv_path(form_id: form.id), params:)
          expect(flash[:success]).to be_nil
        end
      end
    end

    context "when params are invalid" do
      let(:submission_type) { nil }

      it "returns 422" do
        post(receive_csv_path(form_id: form.id), params:)
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not update the form" do
        expect {
          post(receive_csv_path(form_id: form.id), params:)
        }.not_to(change { form.reload.submission_type })
      end

      it "re-renders the page with an error" do
        post(receive_csv_path(form_id: form.id), params:)
        expect(response).to render_template("new")
        expect(response.body).to include(I18n.t("activemodel.errors.models.forms/submission_type_input.attributes.submission_type.blank"))
      end
    end
  end
end
