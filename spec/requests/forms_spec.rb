require "rails_helper"

RSpec.describe "Forms", type: :request do
  describe "Showing an existing form" do
    describe "Given a form" do
      let(:form_data) do
        {
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
        }.to_json
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", {}, form_data, 200
        end

        get form_path(2)
      end

      it "Reads the form from the API" do
        expected_request = ActiveResource::Request.new(:get, "/api/v1/forms/2")
        expect(ActiveResource::HttpMock.requests).to include expected_request
      end
    end
  end

  describe "Editing an existing form" do
    describe "Given a form" do
      let(:form_data) do
        {
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
        }.to_json
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", {}, form_data, 200
        end

        get edit_form_path(2)
      end

      it "Reads the form from the API" do
        expected_request = ActiveResource::Request.new(:get, "/api/v1/forms/2")
        expect(ActiveResource::HttpMock.requests).to include expected_request
      end
    end
  end

  describe "Updating an existing form" do
    describe "Given a form" do
      let(:form_data) do
        {
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
        }.to_json
      end

      let(:updated_form_data) do
        {
          name: "Updated name",
          submission_email: "submission@email.com",
        }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", {}, form_data, 200
          mock.put "/api/v1/forms/2"
        end

        patch form_path(id: 2), params: { form: updated_form_data }
      end

      it "Reads the form from the API" do
        expected_request = ActiveResource::Request.new(:get, "/api/v1/forms/2")
        expect(ActiveResource::HttpMock.requests).to include(expected_request)
      end

      it "Updates the form on the API" do
        expected_request = ActiveResource::Request.new(:put, "/api/v1/forms/2", updated_form_data.to_json)
        expect(ActiveResource::HttpMock.requests).to include(expected_request)
      end

      it "Redirects you to the form overview page" do
        expect(response).to redirect_to(form_path(2))
      end
    end
  end

  describe "Creating a new form" do
    describe "Given a valid form" do
      let(:form_data) do
        {
          name: "Form name",
          submission_email: "submission@email.com",
        }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms", {}, { id: 2 }.to_json, 200
        end

        post "/forms", params: form_data
      end

      it "Redirects you to the form overview page" do
        expect(response).to redirect_to(form_path(2))
      end

      it "Creates the form on the API" do
        expected_request = ActiveResource::Request.new(:post, "/api/v1/forms", form_data.to_json)
        expect(ActiveResource::HttpMock.requests).to include(expected_request)
      end
    end
  end

  describe "Deleting an existing form" do
    describe "Given a valid form" do
      let(:form_data) do
        {
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
        }.to_json
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", {}, form_data, 200
          mock.delete "/api/v1/forms/2"
        end

        delete form_path(id: 2)
      end

      it "Redirects you to the home screen" do
        expect(response).to redirect_to(root_path)
      end

      it "Deletes the form on the API" do
        expected_request = ActiveResource::Request.new(:delete, "/api/v1/forms/2")
        expect(ActiveResource::HttpMock.requests).to include(expected_request)
      end
    end
  end
end
