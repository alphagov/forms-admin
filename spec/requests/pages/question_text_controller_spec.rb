require "rails_helper"

RSpec.describe Pages::QuestionTextController, type: :request do
  let(:form) { create :form }
  let(:pages) { build_list :page, 5, form_id: form.id }

  let(:question_text_input) { build :question_text_input, form: }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  let(:output) { StringIO.new }
  let(:logger) { ActiveSupport::Logger.new(output) }

  before do
    allow(FormRepository).to receive_messages(pages: pages)

    allow(Lograge).to receive(:logger).and_return(logger)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#new" do
    before do
      get question_text_new_path(form_id: form.id)
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

      # We can't unit test the code that adds the logging attributes because it uses CurrentAttributes, so this test has
      # just been added to a controller that does some input validation.
      it "adds validation_errors logging attribute" do
        expect(log_lines[0]["validation_errors"]).to eq(["question_text: blank"])
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

      it "does not add validation_errors logging attribute" do
        expect(log_lines[0].keys).not_to include("validation_errors")
      end
    end
  end

  def log_lines
    output.string.split("\n").map { |line| JSON.parse(line) }
  end
end
