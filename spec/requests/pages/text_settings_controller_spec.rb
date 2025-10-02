require "rails_helper"

RSpec.describe Pages::TextSettingsController, type: :request do
  let(:form) { create :form }
  let(:pages) { build_list :page, 5, form_id: form.id }
  let(:page) { pages.first }

  let(:text_settings_input) { build :text_settings_input }

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
      get text_settings_new_path(form_id: form.id)
    end

    it "sets an instance variable for text_settings_path" do
      path = assigns(:text_settings_path)
      expect(path).to eq text_settings_new_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/text_settings")
    end
  end

  describe "#create" do
    context "when form is invalid" do
      before do
        post text_settings_create_path form_id: form.id, params: { pages_text_settings_input: { input_type: nil } }
      end

      it "renders the text settings view if there are errors" do
        expect(response).to have_rendered("pages/text_settings")
      end
    end

    context "when form is valid and ready to store" do
      before do
        post text_settings_create_path form_id: form.id, params: { pages_text_settings_input: { input_type: text_settings_input.input_type } }
      end

      let(:text_settings_input) { build :text_settings_input }

      it "saves the input type to draft question answers setting" do
        form = assigns(:text_settings_input)
        expect(form.draft_question.answer_settings).to include(input_type: text_settings_input.input_type)
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to new_question_path(form.id)
      end
    end
  end

  describe "#edit" do
    let(:page) { build :page, :with_text_settings, id: 2, form_id: form.id }
    let(:draft_question) do
      create :draft_question,
             answer_type: "text",
             user: standard_user,
             form_id: form.id,
             page_id: page.id,
             answer_settings: {
               input_type: "single_line",
             }
    end

    before do
      allow(PageRepository).to receive(:find).with(page_id: "2", form_id: 1).and_return(page)

      draft_question
      get text_settings_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "returns the existing page input type" do
      form = assigns(:text_settings_input)
      expect(form.input_type).to eq draft_question.answer_settings[:input_type]
    end

    it "sets an instance variable for text_settings_path" do
      path = assigns(:text_settings_path)
      expect(path).to eq text_settings_edit_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/text_settings")
    end
  end

  describe "#update" do
    let(:page) { build :page, :with_text_settings, id: 2, form_id: form.id }

    before do
      allow(PageRepository).to receive(:find).with(page_id: "2", form_id: 1).and_return(page)
      allow(PageRepository).to receive(:save!).with(hash_including(page_id: "2", form_id: 1))
    end

    context "when form is valid and ready to update in the DB" do
      let(:input_type) { "single_line" }

      before do
        post text_settings_update_path(form_id: page.form_id, page_id: page.id), params: { pages_text_settings_input: { input_type: } }
      end

      it "saves the updated input type to DB" do
        form_instance_variable = assigns(:text_settings_input)
        expect(form_instance_variable.input_type).to eq input_type
        expect(form_instance_variable.draft_question.answer_settings)
          .to include({ input_type: })
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to edit_question_path(form.id, page.id)
      end
    end

    context "when form is invalid" do
      let(:input_type) { nil }

      before do
        post text_settings_update_path(form_id: page.form_id, page_id: page.id), params: { pages_text_settings_input: { input_type: } }
      end

      it "renders the text settings view if there are errors" do
        expect(response).to have_rendered("pages/text_settings")
      end
    end
  end
end
