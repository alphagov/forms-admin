require "rails_helper"

RSpec.describe Pages::AddressSettingsController, type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 5, form_id: form.id }

  let(:address_settings_form) { build :address_settings_form, form: }

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

      get address_settings_new_path(form_id: address_settings_form.form.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "sets an instance variable for address_settings_path" do
      path = assigns(:address_settings_path)
      expect(path).to eq address_settings_new_path(address_settings_form.form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/address_settings")
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
        post address_settings_create_path form_id: form.id, params: { pages_address_settings_form: { input_type: nil } }
      end

      it "renders the address settings view if there are errors" do
        expect(response).to have_rendered("pages/address_settings")
      end
    end

    context "when form is valid and ready to store" do
      before do
        post address_settings_create_path form_id: form.id, params: { pages_address_settings_form: { uk_address: address_settings_form.uk_address, international_address: address_settings_form.international_address } }
      end

      let(:address_settings_form) { build :address_settings_form, form: }

      it "saves the input type to session" do
        expect(session[:page][:answer_settings]).to eq({ "input_type": { uk_address: address_settings_form.uk_address, international_address: address_settings_form.international_address } })
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to new_page_path(form.id)
      end
    end
  end

  describe "#edit" do
    let(:page) { build :page, :with_address_settings, id: 2, form_id: form.id }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/2", req_headers, page.to_json, 200
      end

      get address_settings_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "returns the existing page input type" do
      form = assigns(:address_settings_form)
      expect(form.uk_address).to eq page.answer_settings["input_type"]["uk_address"]
      expect(form.international_address).to eq page.answer_settings["input_type"]["international_address"]
    end

    it "sets an instance variable for address_settings_path" do
      path = assigns(:address_settings_path)
      expect(path).to eq address_settings_edit_path(address_settings_form.form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/address_settings")
    end
  end

  describe "#update" do
    let(:page) do
      new_page = build :page, :with_address_settings, id: 2, form_id: form.id
      new_page.answer_settings = { input_type: { uk_address: "false", international_address: "true" } }
      new_page
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/2", req_headers, page.to_json, 200
        mock.put "/api/v1/forms/1/pages/2", post_headers
      end
    end

    context "when form is valid and ready to update in the DB" do
      let(:input_type) { { uk_address:, international_address: } }
      let(:uk_address) { page.answer_settings.input_type.uk_address }
      let(:international_address) { page.answer_settings.input_type.international_address }

      before do
        post address_settings_update_path(form_id: page.form_id, page_id: page.id), params: { pages_address_settings_form: { uk_address: "true", international_address: "false" } }
      end

      it "loads the updated input type into the session from the page params" do
        form_instance_variable = assigns(:address_settings_form)
        expect(form_instance_variable.uk_address).to eq "true"
        expect(form_instance_variable.international_address).to eq "false"
        expect(session[:page][:answer_settings]).to eq({ "input_type": { uk_address: "true", international_address: "false" } })
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to edit_page_path(form.id, page.id)
      end
    end

    context "when form is invalid" do
      let(:input_type) { nil }

      before do
        post address_settings_update_path(form_id: page.form_id, page_id: page.id), params: { pages_address_settings_form: { input_type: } }
      end

      it "renders the address settings view if there are errors" do
        expect(response).to have_rendered("pages/address_settings")
      end
    end
  end
end
