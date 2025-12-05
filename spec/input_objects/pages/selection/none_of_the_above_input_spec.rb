require "rails_helper"

RSpec.describe Pages::Selection::NoneOfTheAboveInput do
  subject(:input) { described_class.new(question_text:, is_optional:, draft_question:) }

  let(:form) { create :form }
  let(:draft_question) { build :selection_draft_question, form_id: form.id }

  let(:question_text) { "Choose an option" }
  let(:is_optional) { "false" }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(input).to be_valid
    end

    describe "question_text" do
      it "is invalid given nil question text" do
        error_message = I18n.t("activemodel.errors.models.pages/selection/none_of_the_above_input.attributes.question_text.blank")
        input.question_text = nil
        expect(input).to be_invalid
        expect(input.errors[:question_text]).to include(error_message)
      end

      it "is invalid given empty string question text" do
        error_message = I18n.t("activemodel.errors.models.pages/selection/none_of_the_above_input.attributes.question_text.blank")
        input.question_text = ""
        expect(input).to be_invalid
        expect(input.errors[:question_text]).to include(error_message)
      end

      it "is invalid if question_text is more than 250 characters" do
        error_message = I18n.t("activemodel.errors.models.pages/selection/none_of_the_above_input.attributes.question_text.too_long", count: 250)
        input.question_text = "a" * 251
        expect(input).to be_invalid
        expect(input.errors[:question_text]).to include(error_message)
      end
    end

    describe "is_optional" do
      it "is valid when is_optional is 'true'" do
        input.is_optional = "true"
        expect(input).to be_valid
      end

      it "is valid when is_optional is 'false'" do
        input.is_optional = "false"
        expect(input).to be_valid
      end

      it "is not valid when is_optional is nil" do
        error_message = I18n.t("activemodel.errors.models.pages/selection/none_of_the_above_input.attributes.is_optional.inclusion")
        input.is_optional = nil
        expect(input).to be_invalid
        expect(input.errors[:is_optional]).to include(error_message)
      end

      it "is not valid when is_optional when not in allowed options" do
        error_message = I18n.t("activemodel.errors.models.pages/selection/none_of_the_above_input.attributes.is_optional.inclusion")
        input.is_optional = "maybe"
        expect(input).to be_invalid
        expect(input.errors[:is_optional]).to include(error_message)
      end
    end
  end

  describe "#submit" do
    context "when input is invalid" do
      let(:question_text) { nil }

      it "returns false" do
        expect(input.submit).to be false
      end
    end

    context "when input is valid" do
      context "when is_optional is 'true'" do
        let(:is_optional) { "true" }

        it "returns true" do
          expect(input.submit).to be true
        end

        it "updates the draft question" do
          input.submit
          expect(input.draft_question.reload.answer_settings).to include(
            none_of_the_above_question: {
              question_text:,
              is_optional:,
            },
          )
        end

        it "does not remove existing answer_settings" do
          input.submit
          expect(input.draft_question.reload.answer_settings.keys).to include(:selection_options, :only_one_option)
        end
      end

      context "when is_optional is 'false'" do
        it "updates the draft question" do
          input.submit
          expect(input.draft_question.reload.answer_settings).to include(
            none_of_the_above_question: {
              question_text:,
              is_optional:,
            },
          )
        end
      end
    end
  end
end
