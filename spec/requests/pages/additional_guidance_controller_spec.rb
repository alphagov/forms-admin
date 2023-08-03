require "rails_helper"

RSpec.describe Pages::AdditionalGuidanceController, type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 5, form_id: form.id }

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
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end

      get additional_guidance_new_path(form_id: form.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/additional_guidance")
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end
      post additional_guidance_new_path(form_id: form.id), params: { pages_additional_guidance_form: { page_heading: "Page heading", additional_guidance_markdown: "## Heading level 2" } }
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/additional_guidance")
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the additional guidance markdown as html" do
      expect(response.body).to include('<h2 class="govuk-heading-l">Heading level 2</h2>')
    end
  end
end
