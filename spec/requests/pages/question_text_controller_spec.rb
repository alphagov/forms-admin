require "rails_helper"

RSpec.describe Pages::QuestionTextController, type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 5, form_id: form.id }

  let(:question_text_input) { build :question_text_input, form: }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    allow(FormRepository).to receive_messages(find: form, pages: pages)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#new" do
    before do
      get question_text_new_path(form_id: form.id)
    end

    it "reads the existing form" do
      expect(FormRepository).to have_received(:find)
    end

    it "sets an instance variable for question_text_path" do
      path = assigns(:question_text_path)
      expect(path).to eq question_text_new_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/question_text")
    end
  end

  describe "#create" do
    context "when form is invalid" do
      before do
        post question_text_create_path form_id: form.id, params: { pages_question_text_input: { question_text: nil } }
      end

      it "renders the date settings view if there are errors" do
        expect(response).to have_rendered("pages/question_text")
      end
    end

    context "when form is valid and ready to store" do
      before do
        post question_text_create_path form_id: form.id, params: { pages_question_text_input: { question_text: "Are you a higher rate taxpayer?" } }
      end

      let(:question_text_input) { build :question_text_input }

      it "saves the question text to the draft question" do
        form = assigns(:question_text_input)
        expect(form.draft_question.question_text).to eq "Are you a higher rate taxpayer?"
      end

      it "redirects the user to the page to choose whether only one option can be selected" do
        expect(response).to redirect_to selection_type_new_path(form.id)
      end
    end
  end
end
