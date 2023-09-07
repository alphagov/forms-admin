require "rails_helper"

RSpec.describe Pages::QuestionTextForm, type: :model do
  let(:form) { build :form, id: 1 }
  let(:question_text_form) { described_class.new }

  it "has a valid factory" do
    question_text_form = build :question_text_form
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
  end

  describe "#submit" do
    let(:session_mock) { {} }

    it "returns false if the form is invalid" do
      expect(question_text_form.submit(session_mock)).to be_falsey
    end

    it "sets a session key called 'page' as a hash with the answer type in it" do
      question_text_form.question_text = "date_of_birth"
      question_text_form.submit(session_mock)
      expect(session_mock[:page][:question_text]).to eq "date_of_birth"
    end
  end
end
