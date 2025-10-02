require "rails_helper"

describe Pages::Selection::TypeController, type: :request do
  let(:form) { create :form }
  let(:pages) { build_list :page, 5, form_id: form.id }
  let(:page) { pages.first }

  let(:only_one_option) { "true" }
  let(:answer_settings) do
    { selection_options: [{ name: "" }, { name: "" }],
      only_one_option: }
  end
  let(:draft_question) do
    create :draft_question,
           answer_type: "selection",
           page_id:,
           user: standard_user,
           form_id: form.id,
           is_optional: false,
           answer_settings:
  end
  let(:page_id) { nil }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    allow(PageRepository).to receive_messages(find: page, save!: page)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#new" do
    before do
      draft_question
      get selection_type_new_path(form_id: form.id)
    end

    it "sets an instance variable for selection_type_path" do
      path = assigns(:selection_type_path)
      expect(path).to eq selection_type_create_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/selection/type")
    end

    context "when draft question does not contain a setting for only_one_option" do
      let(:answer_settings) { {} }

      it "returns nil for only_one_option" do
        selection_type_input = assigns(:selection_type_input)
        expect(selection_type_input.only_one_option).to be_nil
      end
    end

    context "when draft question already contains setting for only_one_option" do
      it "returns the existing draft question answer settings" do
        selection_type_input = assigns(:selection_type_input)
        expect(selection_type_input.only_one_option).to eq "true"
      end
    end
  end

  describe "#create" do
    context "when form is valid and ready to store" do
      before do
        post selection_type_create_path form_id: form.id, params: { pages_selection_type_input: { only_one_option: true } }
      end

      it "saves the the info to draft question" do
        selection_type_input = assigns(:selection_type_input)
        draft_question_settings = selection_type_input.draft_question.answer_settings

        expect(draft_question_settings).to include(only_one_option: "true")
      end

      it "redirects the user to the selection options page" do
        expect(response).to redirect_to selection_options_new_path(form.id)
      end
    end

    context "when form is invalid" do
      before do
        post selection_type_create_path form_id: form.id, params: { pages_selection_type_input: { answer_settings: nil } }
      end

      it "renders the type of answer view if there are errors" do
        expect(response).to have_rendered("pages/selection/type")
      end
    end
  end

  describe "#edit" do
    let(:page) { build :page, :with_selection_settings, id: 2, form_id: form.id }
    let(:page_id) { page.id }

    before do
      allow(PageRepository).to receive(:find).with(page_id: "2", form_id: 1).and_return(page)

      draft_question
      get selection_type_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "returns the existing draft question answer settings" do
      selection_type_input = assigns(:selection_type_input)
      expect(selection_type_input.only_one_option).to eq "true"
    end

    it "sets an instance variable for selection_type_path" do
      path = assigns(:selection_type_path)
      expect(path).to eq selection_type_update_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/selection/type")
    end

    # This ensures there is backwards compatibility for existing questions as we previously set "only_one_option" to
    # "0" rather than "false"
    context "when draft question has a value of '0' for only_one_option" do
      let(:only_one_option) { "0" }

      it "returns the existing draft question answer settings" do
        selection_type_input = assigns(:selection_type_input)
        expect(selection_type_input.only_one_option).to eq "false"
      end
    end
  end

  describe "#update" do
    let(:page) { build :page, id: 2, form_id: form.id }

    before do
      allow(PageRepository).to receive(:find).with(page_id: "2", form_id: 1).and_return(page)
      allow(PageRepository).to receive(:save!).with(hash_including(page_id: "2", form_id: 1))
    end

    context "when form is valid and ready to update in the DB" do
      before do
        post selection_type_update_path form_id: form.id, page_id: page.id, params: { pages_selection_type_input: { only_one_option: true } }
      end

      it "saves the the info to draft question" do
        selection_type_input = assigns(:selection_type_input)
        draft_question_settings = selection_type_input.draft_question.answer_settings

        expect(draft_question_settings).to include(only_one_option: "true")
      end

      it "redirects the user to the selection options page" do
        expect(response).to redirect_to selection_options_edit_path(form.id)
      end
    end

    context "when form is invalid" do
      before do
        post selection_type_update_path form_id: form.id, page_id: page.id, params: { pages_selection_type_input: { answer_settings: nil } }
      end

      it "renders the type of answer view if there are errors" do
        expect(response).to have_rendered("pages/selection/type")
      end
    end
  end
end
