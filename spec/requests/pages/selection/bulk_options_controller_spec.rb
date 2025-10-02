require "rails_helper"

describe Pages::Selection::BulkOptionsController, type: :request do
  let(:form) { create :form }
  let(:pages) { build_list :page, 5, form_id: form.id }
  let(:page) { pages.first }

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
    allow(FormRepository).to receive_messages(pages: pages)
    allow(PageRepository).to receive_messages(find: page, save!: page)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#new" do
    before do
      draft_question
      get selection_bulk_options_new_path(form_id: form.id)
    end

    it "sets an instance variable for back_link_url" do
      path = assigns(:back_link_url)
      expect(path).to eq selection_type_new_path(form.id)
    end

    it "sets an instance variable for bulk_options_path" do
      path = assigns(:bulk_options_path)
      expect(path).to eq selection_bulk_options_new_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/selection/bulk_options")
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
      draft_question
    end

    context "when form is valid and ready to store" do
      before do
        post selection_bulk_options_create_path form_id: form.id, params: { pages_selection_bulk_options_input: { bulk_selection_options: "Option 1\nOption 2", include_none_of_the_above: false } }
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
        post selection_bulk_options_create_path form_id: form.id, params: { pages_selection_bulk_options_input: { bulk_selection_options: "" } }
      end

      it "renders the type of answer view if there are errors" do
        expect(response).to have_rendered("pages/selection/bulk_options")
      end
    end
  end

  describe "#edit" do
    let(:page) { build :page, :with_selection_settings, id: 2, form_id: form.id, answer_settings: }
    let(:answer_settings) { { selection_options: } }
    let(:selection_options) { [{ name: "Option 1" }, { name: "Option 2" }] }
    let(:page_id) { page.id }

    before do
      allow(PageRepository).to receive(:find).with(page_id: "2", form_id: 1).and_return(page)
      draft_question
      get selection_bulk_options_edit_path(form_id: page.form_id, page_id: page.id)
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
      expect(path).to eq selection_bulk_options_edit_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/selection/bulk_options")
    end
  end

  describe "#update" do
    let(:page) { build :page, :with_selection_settings, id: 2, form_id: form.id, answer_settings: }
    let(:answer_settings) { { only_one_option: "true", selection_options: } }
    let(:selection_options) { [{ name: "Option 1" }, { name: "Option 2" }] }

    before do
      allow(PageRepository).to receive(:find).with(page_id: "2", form_id: 1).and_return(page)
      allow(PageRepository).to receive(:save!).with(hash_including(page_id: "2", form_id: 1))
    end

    context "when form is valid and ready to update in the DB" do
      before do
        post selection_bulk_options_update_path(form_id: page.form_id, page_id: page.id), params: { pages_selection_bulk_options_input: { bulk_selection_options: "Option 1\nNew option 2", include_none_of_the_above: false } }
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
        post selection_bulk_options_create_path form_id: form.id, params: { pages_selection_bulk_options_input: { bulk_selection_options: nil } }
      end

      it "renders the bulk selection options view if there are errors" do
        expect(response).to have_rendered("pages/selection/bulk_options")
      end
    end
  end
end
