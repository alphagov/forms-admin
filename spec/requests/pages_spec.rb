require "rails_helper"

RSpec.shared_context "with mocked page requests" do
  let(:form_response) do
    stub_request(:get, "#{ENV['API_BASE']}/api/v1/forms/2")
      .to_return(status: 200, body: { name: "Form name", submission_email: "submission@email.com", id: 2 }.to_json)
  end

  let(:form_pages_response) do
    stub_request(:get, "#{ENV['API_BASE']}/api/v1/forms/2/pages")
      .to_return(status: 200, body: [{
        id: 1,
        form_id: 2,
        question_text: "What is your work address?",
        question_short_name: "Work address",
        hint_text: "This should be the location stated in your contract.",
        answer_type: "address",
      }].to_json)
  end

  let(:page_response) do
    stub_request(:get, "#{ENV['API_BASE']}/api/v1/forms/2/pages/1")
    .to_return(status: 200, body: {
      id: 1,
      form_id: 2,
      question_text: "What is your work address?",
      question_short_name: "Work address",
      hint_text: "This should be the location stated in your contract.",
      answer_type: "address",
    }.to_json)
  end
end

RSpec.describe "Pages", type: :request do
  before do
    User.create!(email: "user@example.com")
  end

  describe "Editing an existing page" do
    describe "Given a page" do
      include_context "with mocked page requests"

      before do
        form_response
        form_pages_response
        page_response
        get edit_page_path(form_id: 2, page_id: 1)
      end

      it "Reads the page from the API" do
        expect(form_response).to have_been_made
        expect(form_pages_response).to have_been_made
        expect(page_response).to have_been_made
      end
    end
  end

  describe "Updating an existing page" do
    describe "Given a page" do
      include_context "with mocked page requests"

      let(:page_update_response) do
        stub_request(:put, "#{ENV['API_BASE']}/api/v1/forms/2/pages/1")
          .with(body: {
            id: 1,
            question_text: "What is your home address?",
            question_short_name: "Home address",
            hint_text: "This should be the location stated in your contract.",
            answer_type: "address",
          }.to_json)
          .to_return(status: 200)
      end

      before do
        form_response
        form_pages_response
        page_response
        page_update_response
        patch update_page_path(form_id: 2, page_id: 1), params: { page: {
          form_id: 2,
          question_text: "What is your home address?",
          question_short_name: "Home address",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
        } }
      end

      it "Reads the page from the API" do
        expect(form_response).to have_been_made
        expect(form_pages_response).to have_been_made
        expect(page_response).to have_been_made
      end

      it "Updates the page on the API" do
        expect(page_update_response).to have_been_made
      end

      it "Redirects you to the page list" do
        expect(response).to redirect_to(pages_path(form_id: 2))
      end
    end
  end

  describe "Creating a new page" do
    describe "Given a valid page" do
      include_context "with mocked page requests"

      let(:page_creation_request) do
        stub_request(:post, "#{ENV['API_BASE']}/api/v1/forms/2/pages")
          .with(body: {
            question_text: "What is your home address?",
            question_short_name: "Home address",
            hint_text: "This should be the location stated in your contract.",
            answer_type: "address",
          })
          .to_return(status: 200, body: {
            question_text: "What is your home address?",
            question_short_name: "Home address",
            hint_text: "This should be the location stated in your contract.",
            answer_type: "address",
            id: 1,
          }.to_json)
      end

      before do
        form_response
        form_pages_response
        page_creation_request
        post create_page_path(2), params: { page: {
          question_text: "What is your home address?",
          question_short_name: "Home address",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
        } }
      end

      it "Redirects you to the page list" do
        expect(response).to redirect_to(pages_path(form_id: 2))
      end

      it "Creates the page on the API" do
        expect(page_creation_request).to have_been_made
      end
    end
  end
end
