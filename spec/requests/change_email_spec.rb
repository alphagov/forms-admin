require "rails_helper"

RSpec.describe "ChangeEmail controller", type: :request do
  let(:form_response_data) do
    {
      id: 2,
      name: "Form name",
      submission_email: "submission@test-org.gov.uk",
      start_page: 1,
      org: "test-org",
      live_at: Time.zone.now,
    }.to_json
  end

  let(:form) do
    Form.new(
      name: "Form name",
      submission_email: "submission@test-org.gov.uk",
      id: 2,
      org: "test-org",
      live_at: Time.zone.now,
    )
  end

  let(:updated_form) do
    Form.new({
      id: 2,
      name: "Form name",
      submission_email: "new_submission@test-org.gov.uk",
      org: "test-org",
      live_at: Time.zone.now,
    })
  end

  let(:req_headers) do
    {
      "X-API-Token" => ENV["API_KEY"],
      "Accept" => "application/json",
    }
  end

  let(:post_headers) do
    {
      "X-API-Token" => ENV["API_KEY"],
      "Content-Type" => "application/json",
    }
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/2", req_headers, form.to_json, 200
      mock.put "/api/v1/forms/2", req_headers
    end

    ActiveResourceMock.mock_resource(form,
                                     {
                                       read: { response: form, status: 200 },
                                       update: { response: updated_form, status: 200 },
                                     })
  end

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put "/api/v1/forms/2", post_headers
        mock.get "/api/v1/forms/2", req_headers, form.to_json, 200
      end
      get change_form_email_path(form_id: 2)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end
  end

  describe "#create" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", req_headers, form.to_json, 200
        mock.put "/api/v1/forms/2", post_headers
      end
      post change_form_email_path(form_id: 2), params: { forms_change_email_form: { submission_email: "new_submission@test-org.gov.uk" } }
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "Updates the form on the API" do
      expect(updated_form).to have_been_updated
    end

    it "Redirects you to the form overview page" do
      expect(response).to redirect_to(form_path(2))
    end
  end
end
