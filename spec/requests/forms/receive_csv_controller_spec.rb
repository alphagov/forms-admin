require "rails_helper"

RSpec.describe Forms::ReceiveCsvController, type: :request do
  let(:form) do
    build(:form, :live, id: 2, submission_type: original_submission_type)
  end

  let(:updated_form) do
    new_form = form
    new_form.submission_type = submission_type
    new_form
  end

  let(:original_submission_type) { "email" }

  let(:submission_type) { nil }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.put "/api/v1/forms/2", post_headers
      mock.get "/api/v1/forms/2", headers, form.to_json, 200
    end

    login_as_super_admin_user
  end

  describe "#new" do
    before do
      get receive_csv_path(form_id: 2)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end
  end

  describe "#create" do
    let(:params) { { forms_receive_csv_input: { submission_type: } } }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.put "/api/v1/forms/2", post_headers
      end

      post receive_csv_path(form_id: 2), params:
    end

    context "when params are valid" do
      let(:submission_type) { "email_with_csv" }

      it "Reads the form from the API" do
        expect(form).to have_been_read
      end

      it "Updates the form on the API" do
        expect(updated_form).to have_been_updated
      end

      it "Redirects you to the form overview page" do
        expect(response).to redirect_to(form_path(2))
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
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the form on the API" do
        expect(form).not_to have_been_updated
      end

      it "re-renders the page with an error" do
        expect(response).to render_template("new")
        expect(response.body).to include(I18n.t("activemodel.errors.models.forms/receive_csv_input.attributes.submission_type.blank"))
      end
    end
  end
end
