require "rails_helper"

describe Pages::SelectionsSettingsController, type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 5, form_id: form.id }

  let(:selections_settings_input) { build :selections_settings_input }

  let(:draft_question) do
    create :draft_question,
           answer_type: "selection",
           page_id:,
           user: editor_user,
           form_id: form.id,
           is_optional: false,
           answer_settings: { selection_options: [{ name: "" }, { name: "" }],
                              only_one_option: false }
  end
  let(:page_id) { nil }

  before do
    group = create :group
    create :membership, group:, user: editor_user
    GroupForm.create! group:, form_id: form.id

    login_as_editor_user
  end

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      end
      draft_question
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

    context "when draft question already contains selection settings" do
      let(:draft_question) do
        create :draft_question,
               answer_type: "selection",
               page_id:,
               user: editor_user,
               form_id: form.id,
               is_optional: true,
               answer_settings: { selection_options: [{ name: "Option 1" }, { name: "Option 2" }],
                                  only_one_option: true }
      end

      it "returns the existing draft question answer settings" do
        settings_form = assigns(:selections_settings_input)
        draft_question_settings = draft_question.answer_settings
        expect(settings_form.only_one_option).to eq draft_question_settings[:only_one_option]
        expect(settings_form.selection_options.map { |option| { name: option[:name] } }).to eq(draft_question_settings[:selection_options].map { |option| { name: option[:name] } })
        expect(settings_form.include_none_of_the_above).to eq draft_question.is_optional
      end
    end
  end

  describe "#create" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      end
    end

    context "when form is valid and ready to store" do
      before do
        post selections_settings_create_path form_id: form.id, params: { pages_selections_settings_input: { selection_options: { "0": { name: "Option 1" }, "1": { name: "Option 2" } }, only_one_option: true, include_none_of_the_above: false } }
      end

      it "saves the the info to draft question" do
        settings_form = assigns(:selections_settings_input)
        draft_question_settings = settings_form.draft_question.answer_settings

        expect(draft_question_settings).to include(only_one_option: "true",
                                                   selection_options: [{ name: "Option 1" }, { name: "Option 2" }])
        expect(settings_form.draft_question.is_optional).to be false
      end

      it "redirects the user to the question details page" do
        expect(response).to redirect_to new_question_path(form.id)
      end
    end

    context "when form is invalid" do
      before do
        post selections_settings_create_path form_id: form.id, params: { pages_selections_settings_input: { answer_settings: nil } }
      end

      it "renders the type of answer view if there are errors" do
        expect(response).to have_rendered("pages/selections_settings")
      end
    end
  end

  describe "#edit" do
    let(:page) { build :page, :with_selections_settings, id: 2, form_id: form.id }
    let(:page_id) { page.id }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/2", headers, page.to_json, 200
      end
      draft_question
      get selections_settings_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "returns the existing draft question answer settings" do
      settings_form = assigns(:selections_settings_input)
      draft_question_settings = settings_form.draft_question.answer_settings
      expect(settings_form.only_one_option).to eq draft_question_settings[:only_one_option]
      expect(settings_form.selection_options.map { |option| { name: option[:name] } }).to eq(draft_question_settings[:selection_options].map { |option| { name: option[:name] } })
      expect(settings_form.include_none_of_the_above).to eq settings_form.draft_question.is_optional
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
    let(:page) { build :page, id: 2, form_id: form.id, answer_settings: selections_settings_input.answer_settings }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/2", headers, page.to_json, 200
        mock.put "/api/v1/forms/1/pages/2", post_headers
      end
    end

    context "when form is valid and ready to update in the DB" do
      before do
        post selections_settings_update_path(form_id: page.form_id, page_id: page.id), params: { pages_selections_settings_input: { selection_options: { "0": { name: "Option 1" }, "1": { name: "New option 2" } }, only_one_option: true, include_none_of_the_above: false } }
      end

      it "saves the updated answer settings to DB" do
        new_settings = { only_one_option: "true", selection_options: [{ name: "Option 1" }, { name: "New option 2" }] }
        form = assigns(:selections_settings_input)
        expect(form.answer_settings).to eq new_settings
      end

      it "redirects the user to the question details page" do
        expect(response).to redirect_to edit_question_path(form.id, page.id)
      end
    end

    context "when form is invalid" do
      before do
        post selections_settings_create_path form_id: form.id, params: { pages_selections_settings_input: { answer_settings: nil } }
      end

      it "renders the selections settings view if there are errors" do
        expect(response).to have_rendered("pages/selections_settings")
      end
    end
  end
end
