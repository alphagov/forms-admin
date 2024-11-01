require "rails_helper"

describe Pages::LongListsSelection::TypeController, type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 5, form_id: form.id }

  let(:draft_question) do
    create :draft_question,
           answer_type: "selection",
           page_id:,
           user: standard_user,
           form_id: form.id,
           is_optional: false,
           answer_settings: { selection_options: [{ name: "" }, { name: "" }],
                              only_one_option: false }
  end
  let(:page_id) { nil }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      end
      draft_question
      get long_lists_selection_type_new_path(form_id: form.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "sets an instance variable for selection_type_path" do
      path = assigns(:selection_type_path)
      expect(path).to eq long_lists_selection_type_create_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/long_lists_selection/type")
    end

    context "when draft question already contains setting for only_one_option" do
      let(:draft_question) do
        create :draft_question,
               answer_type: "selection",
               page_id:,
               user: standard_user,
               form_id: form.id,
               is_optional: true,
               answer_settings: { only_one_option: true }
      end

      it "returns the existing draft question answer settings" do
        selection_type_input = assigns(:selection_type_input)
        draft_question_settings = draft_question.answer_settings
        expect(selection_type_input.only_one_option).to eq draft_question_settings[:only_one_option]
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
        post long_lists_selection_type_create_path form_id: form.id, params: { pages_long_lists_selection_type_input: { only_one_option: true } }
      end

      it "saves the the info to draft question" do
        selection_type_input = assigns(:selection_type_input)
        draft_question_settings = selection_type_input.draft_question.answer_settings

        expect(draft_question_settings).to include(only_one_option: "true")
      end

      it "redirects the user to the selection options page" do
        expect(response).to redirect_to long_lists_selection_options_new_path(form.id)
      end
    end

    context "when form is invalid" do
      before do
        post long_lists_selection_type_create_path form_id: form.id, params: { pages_long_lists_selection_type_input: { answer_settings: nil } }
      end

      it "renders the type of answer view if there are errors" do
        expect(response).to have_rendered("pages/long_lists_selection/type")
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
      get long_lists_selection_type_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "returns the existing draft question answer settings" do
      selection_type_input = assigns(:selection_type_input)
      draft_question_settings = draft_question.answer_settings
      expect(selection_type_input.only_one_option).to eq draft_question_settings[:only_one_option]
    end

    it "sets an instance variable for selection_type_path" do
      path = assigns(:selection_type_path)
      expect(path).to eq long_lists_selection_type_update_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/long_lists_selection/type")
    end
  end

  describe "#update" do
    let(:page) { build :page, id: 2, form_id: form.id }

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
        post long_lists_selection_type_update_path form_id: form.id, page_id: page.id, params: { pages_long_lists_selection_type_input: { only_one_option: true } }
      end

      it "saves the the info to draft question" do
        selection_type_input = assigns(:selection_type_input)
        draft_question_settings = selection_type_input.draft_question.answer_settings

        expect(draft_question_settings).to include(only_one_option: "true")
      end

      it "redirects the user to the selection options page" do
        expect(response).to redirect_to long_lists_selection_options_edit_path(form.id)
      end
    end

    context "when form is invalid" do
      before do
        post long_lists_selection_type_update_path form_id: form.id, page_id: page.id, params: { pages_long_lists_selection_type_input: { answer_settings: nil } }
      end

      it "renders the type of answer view if there are errors" do
        expect(response).to have_rendered("pages/long_lists_selection/type")
      end
    end
  end
end
