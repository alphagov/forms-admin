require "rails_helper"

RSpec.describe "MakeLive controller", type: :request do
  let(:form_response_data) do
    {
      id: 2,
      name: "Form name",
      form_slug: "form-name",
      submission_email: "submission@email.com",
      start_page: 1,
      org: "test-org",
      privacy_policy_url: "https://www.example.gov.uk/privacy-policy",
      live_at: "",
    }.to_json
  end

  let(:page_data) do
    build(:page, form_id: 2).to_json
  end

  let(:form) do
    page = build(:page)

    Form.new(
      name: "Form name",
      form_slug: "form-name",
      submission_email: "submission@email.com",
      id: 2,
      org: "test-org",
      privacy_policy_url: "https://www.example.gov.uk/privacy-policy",
      live_at: "",
      pages: [page],
    )
  end

  let(:updated_form) do
    page = form.pages

    Form.new({
      name: "Form name",
      form_slug: "form-name",
      submission_email: "submission@email.com",
      id: 2,
      org: "test-org",
      privacy_policy_url: "https://www.example.gov.uk/privacy-policy",
      live_at: "2021-01-01T00:00:00.000Z",
      pages: page,
    })
  end

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

  let(:form_params) { nil }

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put "/api/v1/forms/2", post_headers
        mock.get "/api/v1/forms/2", req_headers, form.to_json, 200
      end

      ActiveResourceMock.mock_resource(form,
                                       {
                                         read: { response: form, status: 200 },
                                         update: { response: updated_form, status: 200 },
                                       })
      get make_live_path(id: 2)
    end

    context "when the form is not live" do
      it "Reads the form from the API" do
        expect(form).to have_been_read
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders new" do
        expect(response).to render_template(:new)
      end
    end

    context "when the form is already live" do
      let(:form) do
        Form.new(
          name: "Form name",
          form_slug: "form-name",
          submission_email: "submission@email.com",
          id: 2,
          org: "test-org",
          privacy_policy_url: "https://www.example.com",
          live_at: "2021-01-01T00:00:00.000Z",
        )
      end

      it "Reads the form from the API" do
        expect(form).to have_been_read
      end

      it "redirects to confirmation page" do
        expect(response).to redirect_to(live_confirmation_url(2))
      end
    end
  end

  describe "#confirmation" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put "/api/v1/forms/2", post_headers
        mock.get "/api/v1/forms/2", req_headers, form.to_json, 200
      end
      get live_confirmation_url(id: 2)
    end

    context "when the form is already live" do
      let(:form) do
        Form.new(
          name: "Form name",
          form_slug: "form-name",
          submission_email: "submission@email.com",
          id: 2,
          org: "test-org",
          privacy_policy_url: "https://www.example.com",
          live_at: "2021-01-01T00:00:00.000Z",
        )
      end

      it "Reads the form from the API" do
        expect(form).to have_been_read
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders confirmation" do
        expect(response).to render_template(:confirmation)
      end
    end

    context "when the form is not live" do
      it "Reads the form from the API" do
        expect(form).to have_been_read
      end

      it "redirects to the make_live page" do
        expect(response).to redirect_to(make_live_url(2))
      end
    end
  end

  describe "#create" do
    around do |example|
      Timecop.freeze(Time.zone.local(2021, 1, 1)) do
        example.run
      end
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put "/api/v1/forms/2", post_headers
        mock.get "/api/v1/forms/2", req_headers, form.to_json, 200
      end

      post(make_live_path(id: 2), params: form_params)
    end

    context "when making a form live" do
      let(:form_params) { { forms_make_live_form: { confirm_make_live: :made_live, form: } } }

      it "Reads the form from the API" do
        expect(form).to have_been_read
      end

      it "Updates the form on the API" do
        expect(updated_form).to have_been_updated
      end

      it "redirects you to the confirmation page" do
        expect(response).to redirect_to(live_confirmation_url(2))
      end
    end

    context "when deciding not to make a form live" do
      let(:form_params) { { forms_make_live_form: { confirm_make_live: :not_made_live } } }

      it "Reads the form from the API" do
        expect(form).to have_been_read
      end

      it "does not update the form on the API" do
        expect(form).not_to have_been_updated
      end

      it "redirects you to the form page" do
        expect(response).to redirect_to(form_path(2))
      end
    end
  end
end
