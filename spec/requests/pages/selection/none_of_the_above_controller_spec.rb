require "rails_helper"

describe Pages::Selection::NoneOfTheAboveController, type: :request do
  let(:form) { create :form, :with_pages }
  let(:page) { form.pages.first }

  let(:selection_options) { [{ name: "Option 1" }, { name: "Option 2" }] }
  let(:draft_question) do
    create :draft_question,
           answer_type: "selection",
           page_id: page.id,
           user: standard_user,
           form_id: form.id,
           is_optional: false,
           answer_settings: {
             selection_options:,
             only_one_option: "true",
             none_of_the_above_question: { question_text: "Existing text", is_optional: true },
           }
  end

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#new" do
    before do
      draft_question
      get selection_none_of_the_above_new_path(form_id: form.id)
    end

    it "sets an instance variable for none_of_the_above_path" do
      expect(assigns(:none_of_the_above_path)).to eq selection_none_of_the_above_create_path(form.id)
    end

    context "when there are fewer than 30 selection options" do
      it "sets a back link to the selection options page" do
        expect(assigns(:back_link_url)).to eq selection_options_new_path(form.id)
      end
    end

    context "when there are more than 30 selection options" do
      let(:selection_options) { (1..31).to_a.map { |i| { name: i.to_s } } }

      it "sets a back link to the bulk selection options page" do
        expect(assigns(:back_link_url)).to eq selection_bulk_options_new_path(form.id)
      end
    end

    it "initialises the input with values from the draft question" do
      input = assigns(:none_of_the_above_input)
      expect(input.question_text).to eq "Existing text"
      expect(input.is_optional).to be true
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/selection/none_of_the_above")
    end
  end

  describe "#create" do
    before do
      draft_question
    end

    context "when the input is valid" do
      let(:params) do
        {
          pages_selection_none_of_the_above_input: {
            question_text: "New text",
            is_optional: false,
          },
        }
      end

      before do
        post selection_none_of_the_above_create_path(form_id: form.id), params: params
      end

      it "updates the draft question" do
        expect(draft_question.reload.answer_settings).to eq(
          selection_options: [{ name: "Option 1" }, { name: "Option 2" }],
          only_one_option: "true",
          none_of_the_above_question: { question_text: "New text", is_optional: "false" },
        )
      end

      it "redirects to the question details page" do
        expect(response).to redirect_to new_question_path(form.id)
      end
    end

    context "when the input is invalid" do
      before do
        post selection_none_of_the_above_create_path(form_id: form.id),
             params: { pages_selection_none_of_the_above_input: { question_text: nil, is_optional: true } }
      end

      it "renders the none_of_the_above template" do
        expect(response).to have_rendered("pages/selection/none_of_the_above")
      end
    end
  end

  describe "#edit" do
    before do
      draft_question
      get selection_none_of_the_above_edit_path(form_id: form.id, page_id: page.id)
    end

    it "sets an instance variable for none_of_the_above_path" do
      expect(assigns(:none_of_the_above_path)).to eq selection_none_of_the_above_update_path(form.id, page.id)
    end

    it "sets a back link to edit the question" do
      expect(assigns(:back_link_url)).to eq edit_question_path(form.id)
    end

    it "initialises the input with values from the draft question" do
      input = assigns(:none_of_the_above_input)
      expect(input.question_text).to eq "Existing text"
      expect(input.is_optional).to be true
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/selection/none_of_the_above")
    end
  end

  describe "#update" do
    before do
      draft_question
    end

    context "when input is valid" do
      let(:params) do
        {
          pages_selection_none_of_the_above_input: {
            question_text: "New text",
            is_optional: false,
          },
        }
      end

      before do
        post selection_none_of_the_above_update_path(form_id: form.id, page_id: page.id), params: params
      end

      it "updates the draft question" do
        expect(draft_question.reload.answer_settings).to eq(
          selection_options: [{ name: "Option 1" }, { name: "Option 2" }],
          only_one_option: "true",
          none_of_the_above_question: { question_text: "New text", is_optional: "false" },
        )
      end

      it "redirects to the edit question page" do
        expect(response).to redirect_to edit_question_path(form.id, page.id)
      end
    end

    context "when the input is invalid" do
      before do
        post selection_none_of_the_above_update_path(form_id: form.id, page_id: page.id),
             params: { pages_selection_none_of_the_above_input: { question_text: nil, is_optional: true } }
      end

      it "renders the none_of_the_above template" do
        expect(response).to have_rendered("pages/selection/none_of_the_above")
      end
    end
  end
end
