require "rails_helper"

RSpec.describe Pages::QuestionsController, type: :request do
  let(:form_response) { build :form, id: 2 }

  let(:draft_question) { create :draft_question_for_new_page, user: standard_user, form_id: 2 }

  let(:next_page) { nil }

  let(:page_response) do
    {
      id: 1,
      form_id: 2,
      question_text: draft_question.question_text,
      hint_text: draft_question.hint_text,
      answer_type: draft_question.answer_type,
      answer_settings: nil,
      is_optional: false,
      page_heading: nil,
      guidance_markdown: nil,
      next_page:,
    }
  end

  let(:updated_page_data) do
    {
      id: 1,
      question_text: "What is your home address?",
      hint_text: "This should be the location stated in your contract.",
      answer_type: "address",
      answer_settings: {},
      is_optional: false,
      page_heading: "New page heading",
      guidance_markdown: "## Heading level 2",
      next_page:,
    }
  end

  let(:form_pages_response) do
    [page_response].to_json
  end

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/2", headers, form_response.to_json, 200
      mock.get "/api/v1/forms/2/pages", headers, form_pages_response, 200
      mock.get "/api/v1/forms/2/pages/1", headers, page_response.to_json, 200
      mock.post "/api/v1/forms/2/pages", post_headers, page_response.to_json, 200
      mock.put "/api/v1/forms/2/pages/1", post_headers, updated_page_data.to_json, 200
    end

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form_response.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#new" do
    let(:draft_question) do
      record = create :draft_question_for_new_page, user: standard_user, form_id: 2
      record.question_text = nil
      record.save!(validate: false)
      record.reload
    end

    before do
      draft_question

      get new_question_path(form_id: 2)
    end

    it "Reads the form from the API" do
      expect(form_response).to have_been_read
    end

    it "Reads the pages from the API" do
      form_pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, headers)
      expect(ActiveResource::HttpMock.requests).to include form_pages_request
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    describe "Given a valid page" do
      let(:new_page_data) do
        {
          question_text: "What is your home address?",
          hint_text: "This should be the location stated in your contract.",
          is_optional: false,
          answer_settings: {},
          page_heading: nil,
          guidance_markdown: nil,
          answer_type: draft_question.answer_type,
        }
      end
      let(:params) do
        { pages_question_input: {
          question_text: "What is your home address?",
          hint_text: "This should be the location stated in your contract.",
          is_optional: false,
        } }
      end

      before do
        # Setup a draft_question so that create question action doesn't need to create a completely new records
        draft_question

        post create_question_path(2), params:
      end

      it "Redirects you to edit page for new question" do
        expect(response).to redirect_to(edit_question_path(form_id: 2, page_id: 1))
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

      it "displays a notification banner with call to action links" do
        follow_redirect!
        results = Capybara.string(response.body)
        banner_contents = results.find(".govuk-notification-banner .govuk-notification-banner__content")

        expect(banner_contents).to have_link(text: "Add a question", href: start_new_question_path(form_id: 2))
        expect(banner_contents).to have_link(text: "Back to your questions", href: form_pages_path(form_id: 2))
      end
    end

    context "when question_input has invalid data" do
      before do
        # Setup a draft_question so that create question action doesn't need to create a completely new records
        draft_question

        post create_question_path(2), params: { pages_question_input: {
          hint_text: "This should be the location stated in your contract.",
          is_optional: false,
        } }
      end

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders new template" do
        expect(response).to have_rendered(:new)
      end

      it "outputs error message" do
        expect(response.body).to include("Enter a question")
      end
    end
  end

  describe "#edit" do
    describe "Given a page" do
      before do
        # Setup a draft_question so that edit question action doesn't need to create a completely new records
        draft_question

        get edit_question_path(form_id: 2, page_id: 1)
      end

      it "Reads the page from the API" do
        form_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, headers)
        expect(ActiveResource::HttpMock.requests).to include form_request

        form_pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, headers)
        expect(ActiveResource::HttpMock.requests).to include form_pages_request

        page_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, headers)
        expect(ActiveResource::HttpMock.requests).to include page_request
      end
    end
  end

  describe "#update" do
    let(:draft_question) do
      record = create :draft_question, user: standard_user, form_id: 2
      record.question_text = nil
      record.save!(validate: false)
      record.reload
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
        page_heading: "New page heading",
        guidance_markdown: "## Heading level 2",
        next_page:,
      }
    end

    describe "Given a page" do
      let(:params) do
        { pages_question_input: {
          form_id: 2,
          question_text: "What is your home address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          is_optional: "false",
          page_heading: "New page heading",
          guidance_markdown: "## Heading level 2",
        } }
      end

      before do
        post update_question_path(form_id: 2, page_id: 1), params:
      end

      it "Reads the page from the API" do
        form_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, headers)
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

      it "Redirects you to edit page for question that was updated" do
        expect(response).to redirect_to(edit_question_path(form_id: 2, page_id: 1))
      end

      it "displays a notification banner with call to action links" do
        follow_redirect!
        results = Capybara.string(response.body)
        banner_contents = results.find(".govuk-notification-banner .govuk-notification-banner__content")

        expect(banner_contents).to have_link(text: "Add a question", href: start_new_question_path(form_id: 2))
        expect(banner_contents).to have_link(text: "Back to your questions", href: form_pages_path(form_id: 2))
      end

      context "when question being updated has a question after it" do
        let(:next_page) { 4 }

        let(:params) do
          { pages_question_input: {
            page_id: 1,
            form_id: 2,
            question_text: "What is your home address?",
            hint_text: "This should be the location stated in your contract.",
            answer_type: "address",
            is_optional: "false",
            page_heading: "New page heading",
            guidance_markdown: "## Heading level 2",
          } }
        end

        it "Reads the page from the API" do
          form_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, headers)
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

        it "Redirects you to edit page for new question" do
          expect(response).to redirect_to(edit_question_path(form_id: 2, page_id: 1))
        end

        it "displays a notification banner with call to action links" do
          follow_redirect!
          results = Capybara.string(response.body)
          banner_contents = results.find(".govuk-notification-banner .govuk-notification-banner__content")

          expect(banner_contents).to have_link(text: "Edit next question", href: edit_question_path(form_id: 2, page_id: 4))
          expect(banner_contents).to have_link(text: "Back to your questions", href: form_pages_path(form_id: 2))
        end
      end
    end

    context "when question_input has invalid data" do
      before do
        post update_question_path(form_id: 2, page_id: 1), params: { pages_question_input: {
          form_id: 2,
          question_text: nil,
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          page_heading: "New page heading",
          guidance_markdown: "## Heading level 2",
        } }
      end

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders edit template" do
        expect(response).to have_rendered(:edit)
      end

      it "outputs error message" do
        expect(response.body).to include("Enter a question")
      end
    end
  end
end
