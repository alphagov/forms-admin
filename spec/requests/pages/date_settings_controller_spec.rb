require "rails_helper"

RSpec.describe Pages::DateSettingsController, type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 5, form_id: form.id }

  let(:date_settings_input) { build :date_settings_input }

  let(:group) { create(:group, organisation: editor_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: editor_user, added_by: editor_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_editor_user
  end

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      end

      get date_settings_new_path(form_id: form.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "sets an instance variable for date_settings_path" do
      path = assigns(:date_settings_path)
      expect(path).to eq date_settings_new_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/date_settings")
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
        post date_settings_create_path form_id: form.id, params: { pages_date_settings_input: { input_type: nil } }
      end

      it "renders the date settings view if there are errors" do
        expect(response).to have_rendered("pages/date_settings")
      end
    end

    context "when form is valid and ready to store" do
      before do
        post date_settings_create_path form_id: form.id, params: { pages_date_settings_input: { input_type: "date_of_birth" } }
      end

      let(:date_settings_input) { build :date_settings_input }

      it "saves the input type to Draft Question" do
        form_instance_variable = assigns(:date_settings_input)
        expect(form_instance_variable.draft_question.answer_settings).to include(input_type: "date_of_birth")
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to new_question_path(form.id)
      end
    end
  end

  describe "#edit" do
    let(:page) { build :page, :with_date_settings, id: 2, form_id: form.id }
    let(:draft_question) do
      create :draft_question,
             answer_type: "date",
             user: editor_user,
             form_id: form.id,
             page_id: page.id,
             answer_settings: {
               input_type: "date_of_birth",
             }
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/2", headers, page.to_json, 200
      end
      draft_question
      get date_settings_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "returns the existing page input type" do
      form = assigns(:date_settings_input)
      expect(form.input_type).to eq draft_question.answer_settings[:input_type]
    end

    it "sets an instance variable for date_settings_path" do
      path = assigns(:date_settings_path)
      expect(path).to eq date_settings_edit_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/date_settings")
    end
  end

  describe "#update" do
    let(:page) do
      new_page = build :page, :with_date_settings, id: 2, form_id: form.id
      new_page.answer_settings = { input_type: { uk_date: "false", international_date: "true" } }
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
      let(:input_type) { "date_of_birth" }

      before do
        post date_settings_update_path(form_id: page.form_id, page_id: page.id), params: { pages_date_settings_input: { input_type: "other_date" } }
      end

      it "loads the updated input type from the page params" do
        form_instance_variable = assigns(:date_settings_input)
        expect(form_instance_variable.input_type).to eq "other_date"
        expect(form_instance_variable.draft_question.answer_settings).to include(input_type: "other_date")
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to edit_question_path(form.id, page.id)
      end
    end

    context "when form is invalid" do
      let(:input_type) { nil }

      before do
        post date_settings_update_path(form_id: page.form_id, page_id: page.id), params: { pages_date_settings_input: { input_type: } }
      end

      it "renders the date settings view if there are errors" do
        expect(response).to have_rendered("pages/date_settings")
      end
    end
  end
end
