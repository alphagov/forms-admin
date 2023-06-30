require "rails_helper"

RSpec.describe Forms::ChangeNameController, type: :request do
  let(:form_response_data) do
    {
      id: 2,
      name: "Form name",
      org: "test-org",
      creator_id: 123,
    }.to_json
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

  let(:user) { build :user, id: 1 }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/2", req_headers, form_response_data, 200
      mock.post "/api/v1/forms", post_headers, { id: 2 }.to_json, 200
      mock.put "/api/v1/forms/2", post_headers
    end

    allow(Pundit).to receive(:authorize).and_return(true)

    login_as user
  end

  describe "#create" do
    let(:form_data) do
      {
        name: "Form name",
        org: "test-org",
        creator_id: user.id,
      }
    end

    before do
      ActiveResource::HttpMock.reset!
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/", req_headers, form_response_data, 200
        mock.get "/api/v1/forms/2", req_headers, form_response_data, 200
        mock.put "/api/v1/forms/2", post_headers
        mock.post "/api/v1/forms", post_headers, { id: 2 }.to_json, 200
      end
      post new_form_path, params: { forms_change_name_form: { name: form_data[:name] } }
    end

    it "Redirects you to the form overview page" do
      expect(response).to redirect_to(form_path(2))
    end

    it "Creates the form on the API" do
      form = Form.new(form_data)
      expect(form).to have_been_created
    end

    context "with a trial user" do
      let(:user) { build(:user, :with_trial, :with_no_org, id: 1) }
      let(:form_data) do
        {
          name: "Form name",
          org: nil,
          creator_id: user.id,
          submission_email: user.email,
        }
      end

      it "sets the submission email address" do
        form = Form.new(form_data)
        expect(form).to have_been_created
      end
    end
  end

  describe "#edit" do
    before do
      get change_form_name_path(form_id: 2)
    end

    it "fetches the from from the API" do
      expected_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, req_headers)
      expect(ActiveResource::HttpMock.requests).to include expected_request
    end
  end

  describe "#update" do
    it "renames form" do
      post change_form_name_path(form_id: 2), params: { forms_change_name_form: { name: "new_form_name", org: "test-org", creator_id: 123 } }
      expected_request = ActiveResource::Request.new(:put, "/api/v1/forms/2", { "id": 2, "name": "new_form_name", org: "test-org", creator_id: 123 }.to_json, post_headers)
      expect(ActiveResource::HttpMock.requests).to include expected_request
      expect(ActiveResource::HttpMock.requests[1].body).to eq expected_request.body
      expect(response).to redirect_to(form_path(form_id: 2))
    end
  end
end
