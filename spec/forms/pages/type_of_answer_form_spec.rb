require "rails_helper"

RSpec.describe Pages::TypeOfAnswerForm, type: :model do
  let(:form) { build :form, id: 1 }
  let(:type_of_answer_form) { described_class.new(draft_question:) }
  let(:draft_question) { build :draft_question, form_id: form.id, user: }
  let(:user) { build :user }

  it "has a valid factory" do
    type_of_answer_form = build :type_of_answer_form
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
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      expect(type_of_answer_form.submit).to be_falsey
    end

    it "sets the draft question answer type" do
      type_of_answer_form.answer_type = "email"
      type_of_answer_form.submit
      expect(draft_question.answer_type).to eq("email")
    end
  end
end
