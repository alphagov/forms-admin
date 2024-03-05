require "rails_helper"

RSpec.describe Pages::NameSettingsController, type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 5, form_id: form.id }

  let(:name_settings_form) { build :name_settings_form }

  let(:headers) do
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
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      end

      get name_settings_new_path(form_id: form.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "sets an instance variable for name_settings_path" do
      path = assigns(:name_settings_path)
      expect(path).to eq name_settings_new_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/name_settings")
    end
  end

  describe "#create" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      end
    end

    context "when form is invalid" do
      before do
        post name_settings_create_path form_id: form.id, params: { pages_name_settings_form: { input_type: nil } }
      end

      it "renders the name settings view if there are errors" do
        expect(response).to have_rendered("pages/name_settings")
      end
    end

    context "when form is valid and ready to store" do
      before do
        post name_settings_create_path form_id: form.id, params: { pages_name_settings_form: { input_type: "first_and_last_name", title_needed: "false" } }
      end

      let(:name_settings_form) { build :name_settings_form }

      it "saves the input type to draft question" do
        form = assigns(:name_settings_form)
        expect(form.draft_question.answer_settings).to include(input_type: "first_and_last_name", title_needed: "false")
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to new_question_path(form.id)
      end
    end
  end

  describe "#edit" do
    let(:page) { build :page, :with_name_settings, id: 2, form_id: form.id }
    let(:draft_question) do
      create :draft_question,
             answer_type: "name",
             user: editor_user,
             form_id: form.id,
             page_id: page.id,
             answer_settings: {
               input_type: "first_middle_and_last_name",
               title_needed: "true",
             }
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/2", headers, page.to_json, 200
      end
      draft_question
      get name_settings_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "returns the existing input type" do
      form = assigns(:name_settings_form)
      expect(form.input_type).to eq draft_question.answer_settings[:input_type]
    end

    it "sets an instance variable for name_settings_path" do
      path = assigns(:name_settings_path)
      expect(path).to eq name_settings_edit_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/name_settings")
    end
  end

  describe "#update" do
    let(:page) do
      new_page = build :page, :with_name_settings, id: 2, form_id: form.id
      new_page.answer_settings = { input_type: "first_middle_and_last_name", title_needed: "false" }
      new_page
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/2", headers, page.to_json, 200
        mock.put "/api/v1/forms/1/pages/2", post_headers
      end
    end

    context "when form is valid and ready to update in the DB" do
      let(:input_type) { "full_name" }
      let(:title_needed) { "true" }

      before do
        post name_settings_update_path(form_id: page.form_id, page_id: page.id), params: { pages_name_settings_form: { input_type:, title_needed: } }
      end

      it "loads the updated input type from the page params" do
        form_instance_variable = assigns(:name_settings_form)
        expect(form_instance_variable.input_type).to eq input_type
        expect(form_instance_variable.title_needed).to eq title_needed
        expect(form_instance_variable.draft_question.answer_settings)
          .to include(input_type: "full_name", title_needed: "true")
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to edit_question_path(form.id, page.id)
      end
    end

    context "when form is invalid" do
      let(:input_type) { nil }
      let(:title_needed) { nil }

      before do
        post name_settings_update_path(form_id: page.form_id, page_id: page.id), params: { pages_name_settings_form: { input_type:, title_needed: } }
      end

      it "renders the name settings view if there are errors" do
        expect(response).to have_rendered("pages/name_settings")
      end
    end
  end
end
