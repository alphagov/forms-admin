require "rails_helper"

RSpec.describe Forms::ContactDetailsController, type: :request do
  let(:req_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  let(:post_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Content-Type" => "application/json",
    }
  end

  before do
    login_as_editor_user
  end

  describe "#new" do
    let(:form) do
      build :form, :with_support, id: 2
    end

    before do
      ActiveResourceMock.mock_resource(form, { read: { response: form, status: 200 } })
      get contact_details_path(form_id: 2)
    end

    context "when the does not have any contact details set" do
      it "reads the form from the API" do
        expect(form).to have_been_read
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders new" do
        expect(response).to render_template(:new)
      end
    end
  end

  describe "#create" do
    let(:form) do
      build :form, id: 2
    end

    let(:updated_form) do
      form.tap do |f|
        f.support_email = "test@test.gov.uk"
        f.support_phone = nil
        f.support_url = nil
        f.support_url_text = nil
      end
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put "/api/v1/forms/2", post_headers
        mock.get "/api/v1/forms/2", req_headers, form.to_json, 200
      end

      allow(Pundit).to receive(:authorize).and_return(true)

      post contact_details_create_path(form_id: 2), params:
    end

    context "when given valid params" do
      let(:params) { { forms_contact_details_form: { contact_details_supplied: ["", "supply_email"], email: "test@test.gov.uk", form: } } }

      it "reads the form from the API" do
        expect(form).to have_been_read
      end

      it "updates the form on the API" do
        expect(updated_form).to have_been_updated
      end

      it "redirects to the confirmation page" do
        expect(response).to redirect_to(form_path(form_id: 2))
      end
    end

    context "when given invalid parameters" do
      let(:params) { { forms_contact_details_form: { contact_details_supplied: ["", "supply_email"], email: "", form: } } }

      it "reads the form from the API" do
        expect(form).to have_been_read
      end

      it "does not update the form on the API" do
        expect(updated_form).not_to have_been_updated
      end

      it "shows the error state" do
        expect(response).to render_template(:new)
        expect(response.body).to include I18n.t("error_summary.heading")
      end
    end

    context "when given an email address that does not end in .gov.uk" do
      let(:params) { { forms_contact_details_form: { contact_details_supplied: ["", "supply_email"], email: "a@gmail.com", form: } } }

      it "reads the form from the API" do
        expect(form).to have_been_read
      end

      it "does not update the form on the API" do
        expect(updated_form).not_to have_been_updated
      end

      it "shows the error state" do
        expect(response).to render_template(:new)
        expect(response.body).to include I18n.t("error_summary.heading")
        expect(response.body).to include I18n.t("errors.messages.non_govuk_email")
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
