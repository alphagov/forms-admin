require "rails_helper"

RSpec.describe Forms::ReceiveCsvController, type: :request do
  let(:form) { create(:form, :live, submission_type: original_submission_type) }

  let(:original_submission_type) { "email" }

  let(:submission_type) { nil }

  before do
    allow(FormRepository).to receive_messages(save!: form)

    login_as_super_admin_user
  end

  describe "#create" do
    let(:params) { { forms_receive_csv_input: { submission_type: } } }

    before do
      post receive_csv_path(form_id: form.id), params:
    end

    context "when params are valid" do
      let(:submission_type) { "email_with_csv" }

      it "Updates the form" do
        expect(FormRepository).to have_received(:save!)
      end

      it "Redirects you to the form overview page" do
        expect(response).to redirect_to(form_path(form.id))
      end

      context "when submission type has changed from 'email' to 'email_with_csv'" do
        let(:original_submission_type) { "email" }
        let(:submission_type) { "email_with_csv" }

        it "displays a success flash message" do
          expect(flash[:success]).to eq(I18n.t("banner.success.form.receive_csv_enabled"))
        end
      end

      context "when submission type has changed from 'email_with_csv' to 'email'" do
        let(:original_submission_type) { "email_with_csv" }
        let(:submission_type) { "email" }

        it "displays a success flash message" do
          expect(flash[:success]).to eq(I18n.t("banner.success.form.receive_csv_disabled"))
        end
      end

      context "when submission type has not changed from 'email'" do
        let(:original_submission_type) { "email" }
        let(:submission_type) { "email" }

        it "displays a success flash message" do
          expect(flash[:success]).to be_nil
        end
      end

      context "when submission type has not changed from 'email_with_csv'" do
        let(:original_submission_type) { "email_with_csv" }
        let(:submission_type) { "email_with_csv" }

        it "displays a success flash message" do
          expect(flash[:success]).to be_nil
        end
      end
    end

    context "when params are invalid" do
      let(:submission_type) { nil }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not update the form" do
        expect(FormRepository).not_to have_received(:save!)
      end

      it "re-renders the page with an error" do
        expect(response).to render_template("new")
        expect(response.body).to include(I18n.t("activemodel.errors.models.forms/receive_csv_input.attributes.submission_type.blank"))
      end
    end
  end
end
