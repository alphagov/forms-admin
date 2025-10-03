require "rails_helper"

RSpec.describe Pages::NameSettingsController, type: :request do
  let(:form) { create :form }
  let(:pages) { create_list :page, 5, form: }
  let(:page) { pages.first }

  let(:name_settings_input) { build :name_settings_input }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    allow(PageRepository).to receive_messages(save!: page)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#new" do
    before do
      get name_settings_new_path(form_id: form.id)
    end

    it "sets an instance variable for name_settings_path" do
      path = assigns(:name_settings_path)
      expect(path).to eq name_settings_new_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/name_settings")
    end
  end

  describe "#create" do
    context "when form is invalid" do
      before do
        post name_settings_create_path form_id: form.id, params: { pages_name_settings_input: { input_type: nil } }
      end

      it "renders the name settings view if there are errors" do
        expect(response).to have_rendered("pages/name_settings")
      end
    end

    context "when form is valid and ready to store" do
      before do
        post name_settings_create_path form_id: form.id, params: { pages_name_settings_input: { input_type: "first_and_last_name", title_needed: "false" } }
      end

      let(:name_settings_input) { build :name_settings_input }

      it "saves the input type to draft question" do
        form = assigns(:name_settings_input)
        expect(form.draft_question.answer_settings).to include(input_type: "first_and_last_name", title_needed: "false")
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to new_question_path(form.id)
      end
    end
  end

  describe "#edit" do
    let(:page) { create :page, :with_name_settings, form: }
    let(:draft_question) do
      create :draft_question,
             answer_type: "name",
             user: standard_user,
             form_id: form.id,
             page_id: page.id,
             answer_settings: {
               input_type: "first_middle_and_last_name",
               title_needed: "true",
             }
    end

    before do
      draft_question
      get name_settings_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "returns the existing input type" do
      form = assigns(:name_settings_input)
      expect(form.input_type).to eq draft_question.answer_settings[:input_type]
    end

    it "sets an instance variable for name_settings_path" do
      path = assigns(:name_settings_path)
      expect(path).to eq name_settings_edit_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/name_settings")
    end
  end

  describe "#update" do
    let(:page) do
      new_page = create(:page, :with_name_settings, form:)
      new_page.answer_settings = { input_type: "first_middle_and_last_name", title_needed: "false" }
      new_page
    end

    before do
      allow(PageRepository).to receive(:save!).with(hash_including(page_id: "2", form_id: 1))
    end

    context "when form is valid and ready to update in the DB" do
      let(:input_type) { "full_name" }
      let(:title_needed) { "true" }

      before do
        post name_settings_update_path(form_id: page.form_id, page_id: page.id), params: { pages_name_settings_input: { input_type:, title_needed: } }
      end

      it "loads the updated input type from the page params" do
        form_instance_variable = assigns(:name_settings_input)
        expect(form_instance_variable.input_type).to eq input_type
        expect(form_instance_variable.title_needed).to eq title_needed
        expect(form_instance_variable.draft_question.answer_settings)
          .to include(input_type: "full_name", title_needed: "true")
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to edit_question_path(form.id, page.id)
      end
    end

    context "when form is invalid" do
      let(:input_type) { nil }
      let(:title_needed) { nil }

      before do
        post name_settings_update_path(form_id: page.form_id, page_id: page.id), params: { pages_name_settings_input: { input_type:, title_needed: } }
      end

      it "renders the name settings view if there are errors" do
        expect(response).to have_rendered("pages/name_settings")
      end
    end
  end
end
