require "rails_helper"

describe Pages::Selection::OptionsController, type: :request do
  let(:form) { build :form, id: 1 }
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
                              only_one_option: false }
  end
  let(:page_id) { nil }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    allow(FormRepository).to receive(:find).and_return(form)
    allow(PageRepository).to receive_messages(find: page, save!: page)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      end
      draft_question
      get selection_options_new_path(form_id: form.id)
    end

    it "reads the existing form" do
      expect(FormRepository).to have_received(:find)
    end

    it "sets an instance variable for selection_options_path" do
      path = assigns(:selection_options_path)
      expect(path).to eq selection_options_new_path(form.id)
    end

    it "sets an instance variable for bulk_options_url" do
      path = assigns(:bulk_options_url)
      expect(path).to eq selection_bulk_options_new_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/selection/options")
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
                                  only_one_option: false }
      end

      it "returns the existing draft question answer settings" do
        selection_options_input = assigns(:selection_options_input)
        draft_question_settings = draft_question.answer_settings
        expect(selection_options_input.selection_options.map { |option| { name: option[:name] } }).to eq(draft_question_settings[:selection_options].map { |option| { name: option[:name] } })
        expect(selection_options_input.include_none_of_the_above).to eq draft_question.is_optional
      end
    end
  end

  describe "#create" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      end
      draft_question
    end

    context "when form is valid and ready to store" do
      let(:pages_selection_options_input) do
        {
          selection_options: { "0": { name: "Option 1" }, "1": { name: "Option 2" } },
          include_none_of_the_above: true,
        }
      end

      before do
        post selection_options_create_path form_id: form.id, params: { pages_selection_options_input: }
      end

      it "saves the selection options to the draft question" do
        selection_options_input = assigns(:selection_options_input)
        draft_question_settings = selection_options_input.draft_question.answer_settings

        expect(draft_question_settings).to include(selection_options: [{ name: "Option 1" }, { name: "Option 2" }])
      end

      it "does not overwrite the only_one_option setting on the draft question" do
        selection_options_input = assigns(:selection_options_input)
        draft_question_settings = selection_options_input.draft_question.answer_settings

        expect(draft_question_settings).to include(only_one_option: false)
      end

      it "updates is_optional on the draft question" do
        selection_options_input = assigns(:selection_options_input)

        expect(selection_options_input.draft_question.is_optional).to be true
      end

      it "redirects the user to the question details page" do
        expect(response).to redirect_to new_question_path(form.id)
      end
    end

    context "when form is invalid" do
      before do
        post selection_options_create_path form_id: form.id, params: { pages_selection_options_input: { answer_settings: nil } }
      end

      it "renders the type of answer view if there are errors" do
        expect(response).to have_rendered("pages/selection/options")
      end
    end
  end

  describe "#edit" do
    let(:page) { build :page, :with_selection_settings, id: 2, form_id: form.id }
    let(:page_id) { page.id }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      end

      allow(PageRepository).to receive(:find).with(page_id: "2", form_id: 1).and_return(page)

      draft_question
      get selection_options_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "reads the existing form" do
      expect(FormRepository).to have_received(:find)
    end

    it "returns the existing draft question answer settings" do
      selection_options_input = assigns(:selection_options_input)
      draft_question_settings = draft_question.answer_settings
      expect(selection_options_input.selection_options.map { |option| { name: option[:name] } }).to eq(draft_question_settings[:selection_options].map { |option| { name: option[:name] } })
      expect(selection_options_input.include_none_of_the_above).to eq draft_question.is_optional
    end

    it "sets an instance variable for selections_settings_path" do
      path = assigns(:selection_options_path)
      expect(path).to eq selection_options_edit_path(form.id)
    end

    it "sets an instance variable for bulk_options_url" do
      path = assigns(:bulk_options_url)
      expect(path).to eq selection_bulk_options_edit_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/selection/options")
    end
  end

  describe "#update" do
    let(:page) { build :page, id: 2, form_id: form.id }
    let(:page_id) { page.id }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      end

      allow(PageRepository).to receive(:find).with(page_id: "2", form_id: 1).and_return(page)
      allow(PageRepository).to receive(:save!).with(hash_including(page_id: "2", form_id: 1))

      draft_question
    end

    context "when form is valid and ready to update in the DB" do
      let(:pages_selection_options_input) do
        {
          selection_options: { "0": { name: "Option 1" }, "1": { name: "Option 2" } },
          include_none_of_the_above: true,
        }
      end

      before do
        post selection_options_update_path(form_id: page.form_id, page_id: page.id),
             params: { pages_selection_options_input: }
      end

      it "saves the selection options to the draft question" do
        selection_options_input = assigns(:selection_options_input)
        draft_question_settings = selection_options_input.draft_question.answer_settings

        expect(draft_question_settings).to include(selection_options: [{ name: "Option 1" }, { name: "Option 2" }])
      end

      it "does not overwrite the only_one_option setting on the draft question" do
        selection_options_input = assigns(:selection_options_input)
        draft_question_settings = selection_options_input.draft_question.answer_settings

        expect(draft_question_settings).to include(only_one_option: false)
      end

      it "updates is_optional on the draft question" do
        selection_options_input = assigns(:selection_options_input)

        expect(selection_options_input.draft_question.is_optional).to be true
      end

      it "redirects the user to the question details page" do
        expect(response).to redirect_to edit_question_path(form.id, page.id)
      end
    end

    context "when form is invalid" do
      before do
        post selection_options_update_path form_id: form.id, page_id: page.id, params: { pages_selection_options_input: { answer_settings: nil } }
      end

      it "renders the selection options view if there are errors" do
        expect(response).to have_rendered("pages/selection/options")
      end
    end
  end
end
