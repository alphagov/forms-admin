require "rails_helper"

RSpec.describe Pages::TypeOfAnswerForm, type: :model do
  let(:form) { build :form, id: 1 }
  let(:type_of_answer_form) { described_class.new }

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
    let(:session_mock) { {} }

    it "returns false if the form is invalid" do
      expect(type_of_answer_form.submit(session_mock)).to be_falsey
    end

    it "sets a session key called 'page' as a hash with the answer type in it" do
      type_of_answer_form.answer_type = "email"
      type_of_answer_form.submit(session_mock)
      expect(session_mock[:page]).to include(answer_type: "email")
    end
  end
end
