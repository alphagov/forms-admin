require "rails_helper"

describe Pages::LongListsSelection::BulkOptionsController, type: :request do
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
                              only_one_option: "true" }
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
      get long_lists_selection_bulk_options_new_path(form_id: form.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "sets an instance variable for back_link_url" do
      path = assigns(:back_link_url)
      expect(path).to eq long_lists_selection_type_new_path(form.id)
    end

    it "sets an instance variable for bulk_options_path" do
      path = assigns(:bulk_options_path)
      expect(path).to eq long_lists_selection_bulk_options_new_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/long_lists_selection/bulk_options")
    end

    context "when draft question already contains selection settings" do
      let(:draft_question) do
        create :draft_question,
               answer_type: "selection",
               page_id:,
               user: standard_user,
               form_id: form.id,
               is_optional: true,
               answer_settings: { selection_options: [{ name: "Option 1" }, { name: "Option 2" }],
                                  only_one_option: "true" }
      end

      it "returns the existing draft question answer settings" do
        settings_form = assigns(:bulk_options_input)
        draft_question_settings = draft_question.answer_settings
        expect(settings_form.bulk_selection_options).to eq(draft_question_settings[:selection_options].map { |option| option[:name] }.join("\n"))
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
      draft_question
    end

    context "when form is valid and ready to store" do
      before do
        post long_lists_selection_bulk_options_create_path form_id: form.id, params: { pages_long_lists_selection_bulk_options_input: { bulk_selection_options: "Option 1\nOption 2", include_none_of_the_above: false } }
      end

      it "saves the settings to the draft question" do
        settings_form = assigns(:bulk_options_input)
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
        post long_lists_selection_bulk_options_create_path form_id: form.id, params: { pages_long_lists_selection_bulk_options_input: { bulk_selection_options: "" } }
      end

      it "renders the type of answer view if there are errors" do
        expect(response).to have_rendered("pages/long_lists_selection/bulk_options")
      end
    end
  end

  describe "#edit" do
    let(:page) { build :page, :with_selections_settings, id: 2, form_id: form.id, answer_settings: }
    let(:answer_settings) { { selection_options: } }
    let(:selection_options) { [{ name: "Option 1" }, { name: "Option 2" }] }
    let(:page_id) { page.id }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/2", headers, page.to_json, 200
      end
      draft_question
      get long_lists_selection_bulk_options_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "returns the existing draft question answer settings" do
      settings_form = assigns(:bulk_options_input)
      draft_question_settings = settings_form.draft_question.answer_settings
      expect(settings_form.bulk_selection_options).to eq(draft_question_settings[:selection_options].map { |option| option[:name] }.join("\n"))
      expect(settings_form.include_none_of_the_above).to eq settings_form.draft_question.is_optional
    end

    it "sets an instance variable for back_link_url" do
      path = assigns(:back_link_url)
      expect(path).to eq edit_question_path(form.id, page.id)
    end

    it "sets an instance variable for bulk_options_path" do
      path = assigns(:bulk_options_path)
      expect(path).to eq long_lists_selection_bulk_options_edit_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/long_lists_selection/bulk_options")
    end
  end

  describe "#update" do
    let(:page) { build :page, :with_selections_settings, id: 2, form_id: form.id, answer_settings: }
    let(:answer_settings) { { only_one_option: "true", selection_options: } }
    let(:selection_options) { [{ name: "Option 1" }, { name: "Option 2" }] }

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
        post long_lists_selection_bulk_options_update_path(form_id: page.form_id, page_id: page.id), params: { pages_long_lists_selection_bulk_options_input: { bulk_selection_options: "Option 1\nNew option 2", include_none_of_the_above: false } }
      end

      it "saves the updated answer settings to DB" do
        new_settings = { only_one_option: "true", selection_options: [{ name: "Option 1" }, { name: "New option 2" }] }
        settings_form = assigns(:bulk_options_input)
        draft_question_settings = settings_form.draft_question.answer_settings

        expect(draft_question_settings).to eq new_settings
      end

      it "redirects the user to the question details page" do
        expect(response).to redirect_to edit_question_path(form.id, page.id)
      end
    end

    context "when form is invalid" do
      before do
        post long_lists_selection_bulk_options_create_path form_id: form.id, params: { pages_long_lists_selection_bulk_options_input: { bulk_selection_options: nil } }
      end

      it "renders the bulk selections settings view if there are errors" do
        expect(response).to have_rendered("pages/long_lists_selection/bulk_options")
      end
    end
  end
end
