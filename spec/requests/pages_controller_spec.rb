require "rails_helper"

RSpec.describe PagesController, type: :request do
  let(:form_response) { build :form, id: 2 }

  before do
    login_as_editor_user
  end

  describe "#index" do
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
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
      end

      get form_pages_path(2)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read

      pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, headers)
      expect(ActiveResource::HttpMock.requests).to include pages_request
    end

    context "with a form from another organisation" do
      let(:form) do
        build :form, organisation_id: 2, id: 2
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
        end

        get form_pages_path(2)
      end

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#start_new_question" do
    let(:current_form) { build :form, id: 1 }
    let(:original_draft_question) { create :draft_question, form_id: 1, user: editor_user }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, current_form.to_json, 200
      end
    end

    it "clears draft questions data for current_user" do
      original_draft_question # Setup initial draft question which will clear
      expect {
        get start_new_question_path(form_id: current_form.id)
      }.to change { DraftQuestion.exists?({ user: editor_user }) }.from(true).to(false)
    end

    it "redirects to type_of_answer_create_path" do
      get start_new_question_path(form_id: current_form.id)
      expect(response).to redirect_to(type_of_answer_create_path(form_id: current_form.id))
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

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form_response.to_json, 200
          mock.get "/api/v1/forms/2/pages/1", headers, page.to_json, 200
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

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form_response.to_json, 200
          mock.get "/api/v1/forms/2/pages", headers, form_pages_response, 200
          mock.get "/api/v1/forms/2/pages/1", headers, page.to_json, 200
          mock.put "/api/v1/forms/2", post_headers
          mock.delete "/api/v1/forms/2/pages/1", headers, {}, 200
        end

        delete destroy_page_path(form_id: 2, page_id: 1, forms_delete_confirmation_form: { confirm_deletion: "true" })
      end

      it "Redirects you to the page index screen" do
        expect(response).to redirect_to(form_pages_path)
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
