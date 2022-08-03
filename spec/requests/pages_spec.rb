require "rails_helper"

RSpec.describe "Pages", type: :request do
  before do
    User.create!(email: "user@example.com")
  end

  describe "Editing an existing page" do
    describe "Given a page" do
      let(:form_response) do
        {
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
          org: "test-org",
        }.to_json
      end

      let(:form_pages_response) do
        [{
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          question_short_name: "Work address",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
        }].to_json
      end

      let(:page_response) do
        {
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          question_short_name: "Work address",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
        }.to_json
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", {}, form_response, 200
          mock.get "/api/v1/forms/2/pages", {}, form_pages_response, 200
          mock.get "/api/v1/forms/2/pages/1", {}, page_response, 200
        end

        get edit_page_path(form_id: 2, page_id: 1)
      end

      it "Reads the page from the API" do
        form_request = ActiveResource::Request.new(:get, "/api/v1/forms/2")
        expect(ActiveResource::HttpMock.requests).to include form_request

        form_pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/2")
        expect(ActiveResource::HttpMock.requests).to include form_pages_request

        page_request = ActiveResource::Request.new(:get, "/api/v1/forms/2")
        expect(ActiveResource::HttpMock.requests).to include page_request
      end
    end
  end

  describe "Updating an existing page" do
    describe "Given a page" do
      let(:form_response) do
        {
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
          org: "test-org",
        }.to_json
      end

      let(:form_pages_response) do
        [{
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          question_short_name: "Work address",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
        }].to_json
      end

      let(:page_response) do
        {
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          question_short_name: "Work address",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
        }.to_json
      end

      let(:updated_page_data) do
        {
          question_text: "What is your home address?",
          question_short_name: "Home address",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
        }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", {}, form_response, 200
          mock.get "/api/v1/forms/2/pages", {}, form_pages_response, 200
          mock.get "/api/v1/forms/2/pages/1", {}, page_response, 200
          mock.put "/api/v1/forms/2/pages/1"
        end

        patch update_page_path(form_id: 2, page_id: 1), params: { page: {
          form_id: 2,
          question_text: "What is your home address?",
          question_short_name: "Home address",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
        } }
      end

      it "Reads the page from the API" do
        form_request = ActiveResource::Request.new(:get, "/api/v1/forms/2")
        expect(ActiveResource::HttpMock.requests).to include form_request

        page_request = ActiveResource::Request.new(:put, "/api/v1/forms/2/pages/1")
        expect(ActiveResource::HttpMock.requests).to include page_request
      end

      it "Updates the page on the API" do
        expected_request = ActiveResource::Request.new(:put, "/api/v1/forms/2/pages/1", updated_page_data.to_json)
        expect(ActiveResource::HttpMock.requests).to include(expected_request)
      end

      it "Redirects you to the current edit page" do
        expect(response).to redirect_to(new_page_path(form_id: 2))
      end
    end
  end

  describe "Creating a new page" do
    let(:form_response) do
      {
        name: "Form name",
        submission_email: "submission@email.com",
        id: 2,
        org: "test-org",
      }.to_json
    end

    describe "Given a valid page" do
      let(:new_page_data) do
        {
          question_text: "What is your home address?",
          question_short_name: "Home address",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
        }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", {}, form_response, 200
          mock.get "/api/v1/forms/2/pages", {}, [].to_json, 200
          mock.post "/api/v1/forms/2/pages"
        end

        post create_page_path(2), params: { page: {
          question_text: "What is your home address?",
          question_short_name: "Home address",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
        } }
      end

      it "Redirects you to the page list" do
        expect(response).to redirect_to(new_page_path(form_id: 2))
      end

      it "Creates the page on the API" do
        expected_request = ActiveResource::Request.new(:post, "/api/v1/forms/2/pages", new_page_data.to_json)
        expect(ActiveResource::HttpMock.requests).to include(expected_request)
      end
    end
  end

  describe "Deleting an existing page" do
    describe "Given a valid page" do
      let(:form) do
        Form.new({
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
          org: "test-org",
          start_page: 1,
        })
      end

      let(:page) do
        Page.new({
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          question_short_name: "Work address",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          next: nil,
        })
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", {}, form.to_json, 200
          mock.get "/api/v1/forms/2/pages/1", {}, page.to_json, 200
        end

        get delete_page_path(form_id: 2, page_id: 1)
      end

      it "reads the form from the API" do
        expect(form).to have_been_read
      end

      it "reads the page from the API" do
        expect(page).to have_been_read
      end
    end
  end

  describe "Destroying an existing page" do
    describe "Given a valid page" do
      let(:form) do
        {
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
          org: "test-org",
          start_page: 1,
        }.to_json
      end

      let(:page) do
        Page.new({
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          question_short_name: "Work address",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          next: nil,
        })
      end

      let(:form_pages_response) do
        [page].to_json
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", {}, form, 200
          mock.get "/api/v1/forms/2/pages", {}, form_pages_response, 200
          mock.get "/api/v1/forms/2/pages/1", {}, page.to_json, 200
          mock.put "/api/v1/forms/2"
          mock.delete "/api/v1/forms/2/pages/1", {}, {}, 200
        end

        delete destroy_page_path(form_id: 2, page_id: 1, forms_delete_confirmation_form: { confirm_deletion: "true" })
      end

      it "Redirects you to the home screen" do
        expect(response).to redirect_to(form_path(id: 2))
      end

      it "Deletes the form on the API" do
        expect(page).to have_been_deleted
      end
    end
  end
end
