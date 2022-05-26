require "rails_helper"

RSpec.describe "Forms", type: :request do
  before do
    User.create!(email: "user@example.com")
  end

  describe "Showing an existing form" do
    describe "Given a form" do
      let(:form_response) do
        stub_request(:get, "#{ENV['API_BASE']}/v1/forms/2")
          .to_return(status: 200, body: { name: "Form name", submission_email: "submission@email.com", id: 2 }.to_json)
      end

      before do
        form_response
        get form_path(id: 2)
      end

      it "Reads the form from the API" do
        expect(form_response).to have_been_made
      end
    end
  end

  describe "Editing an existing form" do
    describe "Given a form" do
      let(:form_response) do
        stub_request(:get, "#{ENV['API_BASE']}/v1/forms/2")
          .to_return(status: 200, body: { name: "Form name", submission_email: "submission@email.com", id: 2 }.to_json)
      end

      before do
        form_response
        get edit_form_path(id: 2)
      end

      it "Reads the form from the API" do
        expect(form_response).to have_been_made
      end
    end
  end

  describe "Updating an existing form" do
    describe "Given a form" do
      let(:form_response) do
        stub_request(:get, "#{ENV['API_BASE']}/v1/forms/2")
          .to_return(status: 200, body: { name: "Form name", submission_email: "submission@email.com", id: 2 }.to_json)
      end

      let(:form_update_response) do
        stub_request(:put, "#{ENV['API_BASE']}/v1/forms/2")
          .with(body: { name: "Updated name", submission_email: "submission@email.com", id: 2 })
          .to_return(status: 200)
      end

      before do
        form_response
        form_update_response
        patch form_path(id: 2), params: { form: { name: "Updated name", submission_email: "submission@email.com" } }
      end

      it "Reads the form from the API" do
        expect(form_response).to have_been_made
      end

      it "Updates the form on the API" do
        expect(form_update_response).to have_been_made
      end

      it "Redirects you to the form overview page" do
        expect(response).to redirect_to(form_path(2))
      end
    end
  end

  describe "Creating a new form" do
    describe "Given a valid form" do
      let(:form_creation_request) do
        stub_request(:post, "#{ENV['API_BASE']}/v1/forms")
          .with(body: { name: "Form name", submission_email: "submission@email.com" })
          .to_return(status: 200, body: { name: "Form name", submission_email: "submission@email.com", id: 2 }.to_json)
      end

      before do
        form_creation_request
        post "/forms", params: { name: "Form name", submission_email: "submission@email.com" }
      end

      it "Redirects you to the form overview page" do
        expect(response).to redirect_to(form_path(2))
      end

      it "Creates the form on the API" do
        expect(form_creation_request).to have_been_made
      end
    end
  end
end
