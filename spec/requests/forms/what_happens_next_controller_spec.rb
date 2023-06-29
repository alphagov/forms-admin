require "rails_helper"

RSpec.describe Forms::WhatHappensNextController, type: :request do
  let(:form_response_data) do
    {
      id: 2,
      name: "Form name",
      submission_email: "submission@email.com",
      start_page: 1,
      org: "test-org",
      what_happens_next_text: "Good things come to those who wait",
      live_at: nil,
      has_live_version: false,
    }.to_json
  end

  let(:form) do
    Form.new(
      name: "Form name",
      submission_email: "submission@email.com",
      id: 2,
      org: "test-org",
      what_happens_next_text: "",
      live_at: nil,
      has_live_version: false,
    )
  end

  let(:updated_form) do
    Form.new({
      name: "Form name",
      submission_email: "submission@email.com",
      id: 2,
      org: "test-org",
      what_happens_next_text: "Wait until you get a reply",
      live_at: nil,
      has_live_version: false,
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

    login_as_editor_user
  end

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put "/api/v1/forms/2", post_headers
        mock.get "/api/v1/forms/2", req_headers, form.to_json, 200
      end
      get what_happens_next_path(form_id: 2)
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
      post what_happens_next_path(form_id: 2), params: { forms_what_happens_next_form: { what_happens_next_text: "Wait until you get a reply" } }
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
