require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "Viewing all forms for an organisation" do
    describe "Given a form" do
      let(:forms_response) do
        [{
          id: 2,
          name: "Form",
          submission_email: "submission@email.com",
          org: "test-org",
        },
         {
           id: 3,
           name: "Another form",
           submission_email: "submission@email.com",
           org: "test-org",
         }]
      end

      let(:forms_response_alphabetised) do
        [{
          id: 3,
          name: "Another form",
          submission_email: "submission@email.com",
          org: "test-org",
        },
         {
           id: 2,
           name: "Form",
           submission_email: "submission@email.com",
           org: "test-org",
         }]
      end

      let(:headers) do
        {
          "X-API-Token" => ENV["API_KEY"],
          "Accept" => "application/json",
        }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms?org=test-org", headers, forms_response.to_json, 200
        end
        get root_path
      end

      it "Reads the forms from the API" do
        forms_request = ActiveResource::Request.new(:get, "/api/v1/forms?org=test-org", {}, headers)
        expect(ActiveResource::HttpMock.requests).to include forms_request
      end

      it "Alphabetises the response" do
        forms = assigns(:forms)
        expect(forms.to_json).to eq forms_response_alphabetised.to_json
      end
    end
  end
end
