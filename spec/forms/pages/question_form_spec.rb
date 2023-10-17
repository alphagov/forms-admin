require "rails_helper"

RSpec.describe Pages::QuestionForm, type: :model do
  let(:question_form) { build :question_form, question_text:, draft_question: }
  let(:draft_question) { build :draft_question, question_text: }
  let(:question_text) { "What is your full name?" }

  it "has a valid factory" do
    expect(build(:question_form)).to be_valid
  end

  describe "validations" do
    describe "#question_text" do
      it "is invalid given nil question text" do
        error_message = I18n.t("activemodel.errors.models.pages/question_form.attributes.question_text.blank")
        question_form.question_text = nil
        expect(question_form).not_to be_valid
        expect(question_form.errors[:question_text]).to include(error_message)
      end

      it "is invalid given empty string question text" do
        error_message = I18n.t("activemodel.errors.models.pages/question_form.attributes.question_text.blank")
        question_form.question_text = ""
        expect(question_form).not_to be_valid
        expect(question_form.errors[:question_text]).to include(error_message)
      end

      it "is valid if question text below 200 characters" do
        expect(question_form).to be_valid
      end

      context "when question text 250 characters" do
        let(:question_text) { "A" * 250 }

        it "is valid" do
          expect(question_form).to be_valid
        end
      end

      context "when question text more 250 characters" do
        let(:question_text) { "A" * 251 }

        it "is invalid" do
          expect(question_form).not_to be_valid
        end

        it "has an error message" do
          question_form.valid?
          expect(question_form.errors[:question_text]).to include(I18n.t("activemodel.errors.models.page.attributes.question_text.too_long", count: 250))
        end
      end
    end

    describe "#hint_text" do
      let(:question_form) { build :question_form, hint_text: }
      let(:hint_text) { "Enter your full name as it appears in your passport" }

      it "is valid if hint text is empty" do
        question_form.hint_text = nil
        expect(question_form).to be_valid
      end

      it "is valid if hint text below 500 characters" do
        expect(question_form).to be_valid
      end

      context "when hint text 500 characters" do
        let(:hint_text) { "A" * 500 }

        it "is valid" do
          expect(question_form).to be_valid
        end
      end

      context "when hint text more than 500 characters" do
        let(:hint_text) { "A" * 501 }

        it "is invalid" do
          expect(question_form).not_to be_valid
        end

        it "has an error message" do
          question_form.valid?
          expect(question_form.errors[:hint_text]).to include(I18n.t("activemodel.errors.models.pages/question_form.attributes.hint_text.too_long", count: 500))
        end
      end
    end

    context "when not given a draft_question" do
      let(:draft_question) { nil }

      it "is invalid" do
        expect(question_form).to be_invalid
      end
    end
  end
end
