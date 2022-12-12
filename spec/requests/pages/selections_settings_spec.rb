require "rails_helper"

RSpec.describe "SelectionsSettings controller", type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 5, form_id: form.id }

  let(:selections_settings_form) { build :selections_settings_form }

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

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end

      get selections_settings_new_path(form_id: form.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "sets an instance variable for selections_settings_path" do
      path = assigns(:selections_settings_path)
      expect(path).to eq selections_settings_new_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/selections_settings")
    end
  end

  describe "#create" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end
    end

    context "when form is valid and ready to store" do
      before do
        post selections_settings_create_path form_id: form.id, params: { forms_selections_settings_form: { selection_options: { "0" => { name: "Option 1" }, "1" => { name: "Option 2" } }, only_one_option: true, include_none_of_the_above: false } }
      end

      it "saves the answer type to session" do
        expect(session[:page].to_json).to eq({ "answer_settings": selections_settings_form.answer_settings, is_optional: "false" }.to_json)
      end

      it "redirects the user to the question details page" do
        expect(response).to redirect_to new_page_path(form.id)
      end
    end

    context "when form is invalid" do
      before do
        post selections_settings_create_path form_id: form.id, params: { forms_selections_settings_form: { answer_settings: nil } }
      end

      it "renders the type of answer view if there are errors" do
        expect(response).to have_rendered("pages/selections_settings")
      end
    end
  end

  describe "#edit" do
    let(:page) { build :page, :with_selections_settings, id: 2, form_id: form.id }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/2", req_headers, page.to_json, 200
      end

      get selections_settings_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "returns the existing page answer settings" do
      form = assigns(:selections_settings_form)
      expect(form.answer_settings[:only_one_option]).to eq page.answer_settings[:only_one_option]
      expect(form.answer_settings[:selection_options].map(&:name)).to eq page.answer_settings[:selection_options].map(&:name)
      expect(form.answer_settings[:include_none_of_the_above]).to eq page.is_optional
    end

    it "sets an instance variable for selections_settings_path" do
      path = assigns(:selections_settings_path)
      expect(path).to eq selections_settings_edit_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/selections_settings")
    end
  end

  describe "#update" do
    let(:page) { build :page, id: 2, form_id: form.id, answer_settings: selections_settings_form.answer_settings }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/2", req_headers, page.to_json, 200
        mock.put "/api/v1/forms/1/pages/2", post_headers
      end
    end

    context "when form is valid and ready to update in the DB" do
      before do
        post selections_settings_update_path(form_id: page.form_id, page_id: page.id), params: { forms_selections_settings_form: { selection_options: { "0" => { name: "Option 1" }, "1" => { name: "New option 2" } }, only_one_option: true, include_none_of_the_above: false } }
      end

      it "saves the updated answer settings to DB" do
        new_settings = { only_one_option: "true", selection_options: [Forms::SelectionOption.new({ name: "Option 1" }), Forms::SelectionOption.new({ name: "New option 2" })] }
        form = assigns(:selections_settings_form)
        expect(form.answer_settings.to_json).to eq new_settings.to_json
      end

      it "redirects the user to the question details page " do
        expect(response).to redirect_to edit_page_path(form.id, page.id)
      end
    end

    context "when form is invalid" do
      before do
        post selections_settings_create_path form_id: form.id, params: { forms_selections_settings_form: { answer_settings: nil } }
      end

      it "renders the selections settings view if there are errors" do
        expect(response).to have_rendered("pages/selections_settings")
      end
    end
  end
end
