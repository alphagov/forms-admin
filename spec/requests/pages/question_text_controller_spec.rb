require "rails_helper"

RSpec.describe Pages::QuestionTextController, type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 5, form_id: form.id }

  let(:question_text_form) { build :question_text_form, form: }

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

  before do
    login_as_editor_user
  end

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end

      get question_text_new_path(form_id: form.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "sets an instance variable for question_text_path" do
      path = assigns(:question_text_path)
      expect(path).to eq question_text_new_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/question_text")
    end

    context "editing an existing question text" do
      let!(:draft_question) { create :draft_question, user: editor_user, form_id: form.id }

      it "returns the question text stored in the draft question" do
        expect(response.body).to include(draft_question.question_text)
      end
    end
  end

  describe "#create" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end
    end

    context "when form is invalid" do
      before do
        post question_text_create_path form_id: form.id, params: { pages_question_text_form: { question_text: nil } }
      end

      it "renders the date settings view if there are errors" do
        expect(response).to have_rendered("pages/question_text")
      end
    end

    context "when form is valid and ready to store" do
      before do
        post question_text_create_path form_id: form.id, params: { pages_question_text_form: { question_text: "Are you a higher rate taxpayer?" } }
      end

      let(:question_text_form) { build :question_text_form }

      it "calls the #submit method on the question text form" do
        allow(question_text_form).to receive(:submit).and_return(true)
        expect(question_text_form).to have_received(:submit)
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to selections_settings_new_path(form.id)
      end
    end
  end
end
