require "rails_helper"

RSpec.describe Forms::PrivacyPolicyController, type: :request do
  let(:form) do
    build(:form, :live, id: 2, privacy_policy_url: "https://www.example.com")
  end

  let(:updated_form) do
    new_form = form
    new_form.privacy_policy_url = "https://www.example.gov.uk/privacy-policy"
    new_form
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/2", headers, form.to_json, 200
      mock.put "/api/v1/forms/2", headers
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
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
      end
      get privacy_policy_path(form_id: 2)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end
  end

  describe "#create" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.put "/api/v1/forms/2", post_headers
      end
      post privacy_policy_path(form_id: 2), params: { forms_privacy_policy_input: { privacy_policy_url: "https://www.example.gov.uk/privacy-policy" } }
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
