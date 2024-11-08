require "rails_helper"

RSpec.describe Pages::QuestionInput, type: :model do
  let(:question_input) { build :question_input, question_text:, draft_question:, is_optional:, is_repeatable: }
  let(:draft_question) { build :draft_question, question_text: }
  let(:question_text) { "What is your full name?" }
  let(:is_optional) { "false" }
  let(:is_repeatable) { "false" }

  it "has a valid factory" do
    expect(build(:question_input)).to be_valid
  end

  describe "validations" do
    describe "#question_text" do
      it "is invalid given nil question text" do
        error_message = I18n.t("activemodel.errors.models.pages/question_input.attributes.question_text.blank")
        question_input.question_text = nil
        expect(question_input).not_to be_valid
        expect(question_input.errors[:question_text]).to include(error_message)
      end

      it "is invalid given empty string question text" do
        error_message = I18n.t("activemodel.errors.models.pages/question_input.attributes.question_text.blank")
        question_input.question_text = ""
        expect(question_input).not_to be_valid
        expect(question_input.errors[:question_text]).to include(error_message)
      end

      it "is valid if question text below 200 characters" do
        expect(question_input).to be_valid
      end

      context "when question text 250 characters" do
        let(:question_text) { "A" * 250 }

        it "is valid" do
          expect(question_input).to be_valid
        end
      end

      context "when question text more 250 characters" do
        let(:question_text) { "A" * 251 }

        it "is invalid" do
          expect(question_input).not_to be_valid
        end

        it "has an error message" do
          question_input.valid?
          expect(question_input.errors[:question_text]).to include(I18n.t("activemodel.errors.models.page.attributes.question_text.too_long", count: 250))
        end
      end
    end

    describe "#hint_text" do
      let(:question_input) { build :question_input, hint_text: }
      let(:hint_text) { "Enter your full name as it appears in your passport" }

      it "is valid if hint text is empty" do
        question_input.hint_text = nil
        expect(question_input).to be_valid
      end

      it "is valid if hint text below 500 characters" do
        expect(question_input).to be_valid
      end

      context "when hint text 500 characters" do
        let(:hint_text) { "A" * 500 }

        it "is valid" do
          expect(question_input).to be_valid
        end
      end

      context "when hint text more than 500 characters" do
        let(:hint_text) { "A" * 501 }

        it "is invalid" do
          expect(question_input).not_to be_valid
        end

        it "has an error message" do
          question_input.valid?
          expect(question_input.errors[:hint_text]).to include(I18n.t("activemodel.errors.models.pages/question_input.attributes.hint_text.too_long", count: 500))
        end
      end
    end

    describe "#is_optional" do
      let(:question_input) { build :question_input, is_optional: }

      context "when is_optional is nil" do
        let(:is_optional) { nil }

        it "is invalid" do
          expect(question_input).not_to be_valid
        end

        it "has an error message" do
          question_input.valid?
          expect(question_input.errors[:is_optional]).to include(I18n.t("activemodel.errors.models.pages/question_input.attributes.is_optional.inclusion"))
        end
      end

      context "when is_optional is true" do
        let(:is_optional) { "true" }

        it "is valid" do
          expect(question_input).to be_valid
        end

        it "has no error message" do
          question_input.valid?
          expect(question_input.errors[:is_optional]).to be_empty
        end
      end

      context "when is_optional is false" do
        let(:is_optional) { "false" }

        it "is valid" do
          expect(question_input).to be_valid
        end

        it "has no error message" do
          question_input.valid?
          expect(question_input.errors[:is_optional]).to be_empty
        end
      end
    end

    describe "#is_repeatable" do
      let(:question_input) { build :question_input, is_repeatable: }

      context "when feature repeatable page is not enabled", feature_repeatable_page_enabled: false do
        context "and is_repeatable is nil" do
          let(:is_repeatable) { nil }

          it "is valid" do
            expect(question_input).to be_valid
          end

          it "has no error message" do
            question_input.valid?
            expect(question_input.errors[:is_repeatable]).to be_empty
          end
        end
      end

      context "when feature repeatable page is enabled", :feature_repeatable_page_enabled do
        context "and is_repeatable is nil" do
          let(:is_repeatable) { nil }

          it "is invalid" do
            expect(question_input).not_to be_valid
          end

          it "has an error message" do
            question_input.valid?
            expect(question_input.errors[:is_repeatable]).to include(I18n.t("activemodel.errors.models.pages/question_input.attributes.is_repeatable.inclusion"))
          end
        end

        context "and is_repeatable is true" do
          let(:is_repeatable) { "true" }

          it "is valid" do
            expect(question_input).to be_valid
          end

          it "has no error message" do
            question_input.valid?
            expect(question_input.errors[:is_repeatable]).to be_empty
          end
        end

        context "and is_repeatable is false" do
          let(:is_repeatable) { "false" }

          it "is valid" do
            expect(question_input).to be_valid
          end

          it "has no error message" do
            question_input.valid?
            expect(question_input.errors[:is_repeatable]).to be_empty
          end
        end
      end
    end

    context "when not given a draft_question" do
      let(:draft_question) { nil }

      it "is invalid" do
        expect(question_input).to be_invalid
      end
    end

    describe "selection options" do
      let(:selection_options) { (1..31).to_a.map { |i| { name: i.to_s } } }
      let(:only_one_option) { "false" }
      let(:draft_question) { build :selection_draft_question, answer_settings: { selection_options:, only_one_option: } }

      context "when only_one_option is true" do
        let(:only_one_option) { "true" }

        context "when there are more than 30 options" do
          it "is valid" do
            expect(question_input).to be_valid
          end
        end
      end

      context "when only_one_option is false" do
        context "when there are 30 options" do
          let(:selection_options) { (1..30).to_a.map { |i| { name: i.to_s } } }

          it "is valid" do
            expect(question_input).to be_valid
          end
        end

        context "when there are more than 30 options" do
          it "is invalid" do
            expect(question_input).to be_invalid
            expect(question_input.errors[:selection_options])
              .to include(I18n.t("activemodel.errors.models.pages/question_input.attributes.selection_options.too_many_selection_options"))
          end
        end
      end

      context "when answer type is not selection" do
        let(:draft_question) { build :name_draft_question, answer_settings: { selection_options:, only_one_option: } }

        it "is valid" do
          expect(question_input).to be_valid
        end
      end
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      allow(question_input).to receive(:invalid?).and_return(true)
      expect(question_input.submit).to be false
    end

    context "when form is valid valid" do
      before do
        question_input.question_text = "How old are you?"
        question_input.hint_text = "As a number"
        question_input.is_optional = "false"
        question_input.is_repeatable = "true"
        question_input.submit
      end

      it "sets a draft_question question_text" do
        expect(question_input.draft_question.question_text).to eq question_input.question_text
      end

      it "sets a draft_question hint_text" do
        expect(question_input.draft_question.hint_text).to eq question_input.hint_text
      end

      it "sets a draft_question is_optional" do
        expect(question_input.draft_question.is_optional.to_s).to eq question_input.is_optional
      end

      it "sets a draft_question is_repeatable" do
        expect(question_input.draft_question.is_repeatable.to_s).to eq question_input.is_repeatable
      end
    end
  end
end
