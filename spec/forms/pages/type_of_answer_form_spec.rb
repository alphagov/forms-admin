require "rails_helper"

RSpec.describe Pages::TypeOfAnswerForm, type: :model do
  let(:type_of_answer_form) { build :type_of_answer_form, draft_question: }
  let(:draft_question) { build :draft_question, form_id: 1 }

  it "has a valid factory" do
    type_of_answer_form = build(:type_of_answer_form, draft_question:)
    expect(type_of_answer_form).to be_valid
  end

  describe "validations" do
    it "is invalid if not given a type of answer" do
      type_of_answer_form.answer_type = nil
      expect(type_of_answer_form).to be_invalid
    end

    it "is invalid given an empty string answer_type" do
      type_of_answer_form.answer_type = ""
      expect(type_of_answer_form).to be_invalid
    end

    it "is valid if answer type is a valid page answer type" do
      Page::ANSWER_TYPES.each do |answer_type|
        type_of_answer_form.answer_type = answer_type
        expect(type_of_answer_form).to be_valid "#{answer_type} is not a Page answer type"
      end
    end

    context "when not given a draft_question" do
      let(:draft_question) { nil }

      it "is invalid" do
        expect(type_of_answer_form).to be_invalid
      end
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      allow(type_of_answer_form).to receive(:invalid?).and_return(true)
      expect(type_of_answer_form.submit).to be_falsey
    end

    it "sets draft_question to the answer type" do
      type_of_answer_form.answer_type = "email"
      type_of_answer_form.submit
      expect(type_of_answer_form.draft_question.answer_type).to eq("email")
    end

    it "sets clears the answer_settings for the draft_question" do
      type_of_answer_form.answer_type = "email"
      type_of_answer_form.submit
      expect(type_of_answer_form.draft_question.answer_settings).to eq({})
    end

    context "when data is valid and answer_type_changed is false" do
      before do
        allow(type_of_answer_form).to receive(:invalid?).and_return(false)
        allow(type_of_answer_form).to receive(:answer_type_changed?).and_return(false)
      end

      it "returns true" do
        expect(type_of_answer_form.submit).to eq true
      end

      it "does not call save on draft_question" do
        expect(draft_question).not_to receive(:save!)
        type_of_answer_form.submit
      end
    end
  end
end
