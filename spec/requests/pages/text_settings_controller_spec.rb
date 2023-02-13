require "rails_helper"

RSpec.describe Pages::TextSettingsController, type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 5, form_id: form.id }

  let(:text_settings_form) { build :text_settings_form, form: }

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

      get text_settings_new_path(form_id: text_settings_form.form.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "sets an instance variable for text_settings_path" do
      path = assigns(:text_settings_path)
      expect(path).to eq text_settings_new_path(text_settings_form.form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/text_settings")
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
        post text_settings_create_path form_id: form.id, params: { forms_text_settings_form: { input_type: nil } }
      end

      it "renders the text settings view if there are errors" do
        expect(response).to have_rendered("pages/text_settings")
      end
    end

    context "when form is valid and ready to store" do
      before do
        post text_settings_create_path form_id: form.id, params: { forms_text_settings_form: { input_type: text_settings_form.input_type } }
      end

      let(:text_settings_form) { build :text_settings_form, form: }

      it "saves the input type to session" do
        expect(session[:page][:answer_settings]).to eq({ "input_type": text_settings_form.input_type })
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to new_page_path(form.id)
      end
    end
  end

  describe "#edit" do
    let(:page) { build :page, :with_text_settings, id: 2, form_id: form.id }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/2", req_headers, page.to_json, 200
      end

      get text_settings_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "returns the existing page input type" do
      form = assigns(:text_settings_form)
      expect(form.input_type).to eq page.answer_settings["input_type"]
    end

    it "sets an instance variable for text_settings_path" do
      path = assigns(:text_settings_path)
      expect(path).to eq text_settings_edit_path(text_settings_form.form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/text_settings")
    end
  end

  describe "#update" do
    let(:page) { build :page, :with_text_settings, id: 2, form_id: form.id }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/2", req_headers, page.to_json, 200
        mock.put "/api/v1/forms/1/pages/2", post_headers
      end
    end

    context "when form is valid and ready to update in the DB" do
      let(:input_type) { "single_line" }

      before do
        post text_settings_update_path(form_id: page.form_id, page_id: page.id), params: { forms_text_settings_form: { input_type: } }
      end

      it "saves the updated input type to DB" do
        form_instance_variable = assigns(:text_settings_form)
        expect(form_instance_variable.input_type).to eq input_type
        expect(session[:page][:answer_settings]).to eq({ input_type: })
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to edit_page_path(form.id, page.id)
      end
    end

    context "when form is invalid" do
      let(:input_type) { nil }

      before do
        post text_settings_update_path(form_id: page.form_id, page_id: page.id), params: { forms_text_settings_form: { input_type: } }
      end

      it "renders the text settings view if there are errors" do
        expect(response).to have_rendered("pages/text_settings")
      end
    end
  end
end
