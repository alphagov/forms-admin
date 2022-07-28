require "rails_helper"

RSpec.describe "ChangeName controller", type: :request do
  let(:form_data) do
    {
      name: "Form name",
      submission_email: "",
      org: "test-org",
    }
  end

  let(:form_response_data) do
    {
      id: 2,
      name: "Form name",
      submission_email: "submission@email.com",
      start_page: 1,
      org: "test-org",
    }.to_json
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/2", {}, form_response_data, 200
      mock.post "/api/v1/forms", {}, { id: 2 }.to_json, 200
      mock.put "/api/v1/forms/2"
    end
  end

  describe "#create" do
    before do
      post new_form_path, params: { forms_change_name_form: { name: form_data[:name] } }
    end

    it "Redirects you to the form overview page" do
      expect(response).to redirect_to(form_path(2))
    end

    it "Creates the form on the API" do
      form = Form.new(form_data)
      expect(form).to have_been_created
    end
  end

  describe "#edit" do
    before do
      get change_form_name_path(id: 2)
    end

    it "fetches the from from the API" do
      expected_request = ActiveResource::Request.new(:get, "/api/v1/forms/2")
      expect(ActiveResource::HttpMock.requests).to include expected_request
    end
  end

  describe "#update" do
    it "renames form" do
      post change_form_name_path(id: 2), params: { forms_change_name_form: { name: "new_form_name" } }
      expected_request = ActiveResource::Request.new(:put, "/api/v1/forms/2", { "id": 2, "name": "new_form_name", "submission_email": "submission@email.com", "start_page": 1, org: "test-org" }.to_json)
      expect(ActiveResource::HttpMock.requests).to include expected_request
      expect(ActiveResource::HttpMock.requests[1].body).to eq expected_request.body
      expect(response).to redirect_to(form_path(id: 2))
    end
  end
end
