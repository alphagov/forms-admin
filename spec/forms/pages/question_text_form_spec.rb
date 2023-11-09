require "rails_helper"

RSpec.describe Pages::QuestionTextForm, type: :model do
  let(:question_text_form) { build :question_text_form, draft_question: }
  let(:draft_question) { build :draft_question, answer_type: "selection", form_id: 1 }

  it "has a valid factory" do
    expect(question_text_form).to be_valid
  end

  describe "validations" do
    [nil, ""].each do |question_text|
      it "is invalid given {question_text} question text" do
        error_message = I18n.t("activemodel.errors.models.pages/question_text_form.attributes.question_text.blank")
        question_text_form.question_text = question_text
        expect(question_text_form).to be_invalid
        expect(question_text_form.errors.full_messages_for(:question_text)).to include("Question text #{error_message}")
      end
    end

    ["A" * 10, "A" * 250].each do |question_text|
      it "is valid if question text is less than or equal to 250 characters" do
        question_text_form.question_text = question_text
        expect(question_text_form).to be_valid
      end
    end

    it "is invalid if question text is more than 250 characters" do
      question_text_form.question_text = "A" * 251
      expect(question_text_form).not_to be_valid
      error_message = I18n.t("activemodel.errors.models.pages/question_text_form.attributes.question_text.too_long", count: 250)
      expect(question_text_form.errors.full_messages_for(:question_text)).to include("Question text #{error_message}")
    end

    context "when not given a draft_question" do
      let(:draft_question) { nil }

      it "is invalid" do
        expect(question_text_form).to be_invalid
      end
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      allow(question_text_form).to receive(:invalid?).and_return(true)
      expect(question_text_form.submit).to be_falsey
    end

    it "sets draft_question question_text" do
      question_text_form.question_text = "What is your name?"
      question_text_form.submit

      expect(question_text_form.draft_question.question_text).to eq("What is your name?")
    end
  end
end
