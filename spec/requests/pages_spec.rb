require "rails_helper"

RSpec.describe "Pages", type: :request do
  let(:headers) do
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

  let(:form_response) do
    (build :form, id: 2)
  end

  describe "Editing an existing page" do
    describe "Given a page" do
      let(:form_pages_response) do
        [{
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          answer_settings: nil,
        }].to_json
      end

      let(:page_response) do
        {
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          answer_settings: nil,
          is_optional: false,
        }.to_json
      end

      let(:req_headers) do
        {
          "X-API-Token" => ENV["API_KEY"],
          "Accept" => "application/json",
        }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", req_headers, form_response.to_json, 200
          mock.get "/api/v1/forms/2/pages", req_headers, form_pages_response, 200
          mock.get "/api/v1/forms/2/pages/1", req_headers, page_response, 200
        end

        get edit_page_path(form_id: 2, page_id: 1)
      end

      it "Reads the page from the API" do
        form_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, req_headers)
        expect(ActiveResource::HttpMock.requests).to include form_request

        form_pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, req_headers)
        expect(ActiveResource::HttpMock.requests).to include form_pages_request

        page_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, req_headers)
        expect(ActiveResource::HttpMock.requests).to include page_request
      end
    end
  end

  describe "Updating an existing page" do
    describe "Given a page" do
      let(:form_pages_response) do
        [{
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          answer_settings: nil,
          is_optional: false,
        }].to_json
      end

      let(:page_response) do
        {
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          answer_settings: nil,
          is_optional: false,
        }.to_json
      end

      let(:updated_page_data) do
        {
          id: 1,
          question_text: "What is your home address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          answer_settings: nil,
          is_optional: nil,
        }
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
          mock.get "/api/v1/forms/2", req_headers, form_response.to_json, 200
          mock.get "/api/v1/forms/2/pages", req_headers, form_pages_response, 200
          mock.get "/api/v1/forms/2/pages/1", req_headers, page_response, 200
          mock.put "/api/v1/forms/2/pages/1", post_headers
        end

        patch update_page_path(form_id: 2, page_id: 1), params: { page: {
          form_id: 2,
          question_text: "What is your home address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
        } }
      end

      it "Reads the page from the API" do
        form_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, req_headers)
        expect(ActiveResource::HttpMock.requests).to include form_request

        page_request = ActiveResource::Request.new(:put, "/api/v1/forms/2/pages/1", {}, post_headers)
        expect(ActiveResource::HttpMock.requests).to include page_request
      end

      it "Updates the page on the API" do
        expected_request = ActiveResource::Request.new(:put, "/api/v1/forms/2/pages/1", updated_page_data.to_json, post_headers)
        matched_request = ActiveResource::HttpMock.requests.find do |request|
          request.method == expected_request.method &&
            request.path == expected_request.path &&
            request.body == expected_request.body
        end

        expect(matched_request).to eq expected_request
      end

      it "Redirects you to the new type of answer page" do
        expect(response).to redirect_to(type_of_answer_create_path(form_id: 2))
      end
    end
  end

  describe "Creating a new page" do
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

    describe "Given a valid page" do
      let(:new_page_data) do
        {
          question_text: "What is your home address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          is_optional: nil,
          answer_settings: nil,
        }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", req_headers, form_response.to_json, 200
          mock.get "/api/v1/forms/2/pages", req_headers, [].to_json, 200
          mock.post "/api/v1/forms/2/pages", post_headers
        end

        post create_page_path(2), params: { page: {
          question_text: "What is your home address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          is_optional: false,
        } }
      end

      it "Redirects you to a new type of answer page" do
        expect(response).to redirect_to(type_of_answer_new_path(form_id: 2))
      end

      it "Creates the page on the API" do
        expected_request = ActiveResource::Request.new(:post, "/api/v1/forms/2/pages", new_page_data.to_json, post_headers)
        matched_request = ActiveResource::HttpMock.requests.find do |request|
          request.method == expected_request.method &&
            request.path == expected_request.path &&
            request.body == expected_request.body
        end

        expect(matched_request).to eq expected_request
      end
    end
  end

  describe "Deleting an existing page" do
    describe "Given a valid page" do
      let(:page) do
        Page.new({
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          next_page: nil,
          is_optional: false,
        })
      end

      let(:req_headers) do
        {
          "X-API-Token" => ENV["API_KEY"],
          "Accept" => "application/json",
        }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", req_headers, form_response.to_json, 200
          mock.get "/api/v1/forms/2/pages/1", req_headers, page.to_json, 200
        end

        get delete_page_path(form_id: 2, page_id: 1)
      end

      it "reads the form from the API" do
        expect(form_response).to have_been_read
      end

      it "reads the page from the API" do
        expect(page).to have_been_read
      end
    end
  end

  describe "Destroying an existing page" do
    describe "Given a valid page" do
      let(:page) do
        Page.new({
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          next_page: nil,
        })
      end

      let(:form_pages_response) do
        [page].to_json
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
          mock.get "/api/v1/forms/2", req_headers, form_response.to_json, 200
          mock.get "/api/v1/forms/2/pages", req_headers, form_pages_response, 200
          mock.get "/api/v1/forms/2/pages/1", req_headers, page.to_json, 200
          mock.put "/api/v1/forms/2", post_headers
          mock.delete "/api/v1/forms/2/pages/1", req_headers, {}, 200
        end

        delete destroy_page_path(form_id: 2, page_id: 1, forms_delete_confirmation_form: { confirm_deletion: "true" })
      end

      it "Redirects you to the home screen" do
        expect(response).to redirect_to(form_path(form_id: 2))
      end

      it "Deletes the form on the API" do
        expect(page).to have_been_deleted
      end
    end
  end

  describe "#move_page" do
    let(:pages) do
      [build(:page, id: 99),
       build(:page, id: 100),
       build(:page, id: 101)]
    end
    let(:form) do
      build(:form, id: 2, pages:)
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/100", headers, pages[1].to_json, 200
        mock.put "/api/v1/forms/1/pages/100/up", post_headers
      end

      post move_page_path({ form_id: 1, move_direction: { up: 100 } })
    end

    it "Reads the form from the API" do
      move_post = ActiveResource::Request.new(:put, "/api/v1/forms/1/pages/100/up", {}, post_headers)
      expect(ActiveResource::HttpMock.requests).to include move_post
    end
  end
end
