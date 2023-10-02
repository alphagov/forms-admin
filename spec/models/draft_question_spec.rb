require "rails_helper"

RSpec.describe DraftQuestion, type: :model do
  let(:draft_question) { build(:draft_question, user:, question_text:) }
  let(:user) { build :user }
  let(:question_text) { "What is your full name?" }

  it "has a valid factory" do
    expect(build(:draft_question, user:)).to be_valid
  end

  describe "validations" do
    it "requires a form_id" do
      draft_question.form_id = nil
      expect(draft_question).not_to be_valid
    end

    describe "#question_text" do
      it "is invalid given nil question text" do
        error_message = I18n.t("activerecord.errors.models.draft_question.attributes.question_text.blank")
        draft_question.question_text = nil
        expect(draft_question).not_to be_valid
        expect(draft_question.errors[:question_text]).to include(error_message)
      end

      it "is invalid given empty string question text" do
        error_message = I18n.t("activerecord.errors.models.draft_question.attributes.question_text.blank")
        draft_question.question_text = ""
        expect(draft_question).not_to be_valid
        expect(draft_question.errors[:question_text]).to include(error_message)
      end

      it "is valid if question text below 200 characters" do
        expect(draft_question).to be_valid
      end

      context "when question text 250 characters" do
        let(:question_text) { "A" * 250 }

        it "is valid" do
          expect(draft_question).to be_valid
        end
      end

      context "when question text more 250 characters" do
        let(:question_text) { "A" * 251 }

        it "is invalid" do
          expect(draft_question).not_to be_valid
        end

        it "has an error message" do
          draft_question.valid?
          expect(draft_question.errors[:question_text]).to include(I18n.t("activerecord.errors.models.draft_question.attributes.question_text.too_long", count: 250))
        end
      end
    end

    describe "#hint_text" do
      let(:draft_question) { build :draft_question, user:, hint_text: }
      let(:hint_text) { "Enter your full name as it appears in your passport" }

      it "is valid if hint text is empty" do
        draft_question.hint_text = nil
        expect(draft_question).to be_valid
      end

      it "is valid if hint text below 500 characters" do
        expect(draft_question).to be_valid
      end

      context "when hint text 500 characters" do
        let(:hint_text) { "A" * 500 }

        it "is valid" do
          expect(draft_question).to be_valid
        end
      end

      context "when hint text more than 500 characters" do
        let(:hint_text) { "A" * 501 }

        it "is invalid" do
          expect(draft_question).not_to be_valid
        end

        it "has an error message" do
          draft_question.valid?
          expect(draft_question.errors[:hint_text]).to include(I18n.t("activerecord.errors.models.draft_question.attributes.hint_text.too_long", count: 500))
        end
      end
    end

    describe "#guidance" do
      let(:draft_question) { build :draft_question, :with_guidance, user: }

      it "is invalid if page heading is nil" do
        error_message = I18n.t("activerecord.errors.models.draft_question.attributes.page_heading.blank")
        draft_question.page_heading = nil
        expect(draft_question).to be_invalid
        expect(draft_question.errors.full_messages_for(:page_heading)).to include("Page heading #{error_message}")
      end

      it "is invalid if guidance_markdown is nil" do
        error_message = I18n.t("activerecord.errors.models.draft_question.attributes.guidance_markdown.blank")
        draft_question.guidance_markdown = nil
        expect(draft_question).to be_invalid
        expect(draft_question.errors.full_messages_for(:guidance_markdown)).to include("Guidance markdown #{error_message}")
      end

      context "when page_heading and guidance_markdown are not blank" do
        let(:page_heading) { "New guidance heading" }
        let(:guidance_markdown) { "## Level heading 2" }

        it "is valid" do
          expect(draft_question).to be_valid
        end
      end

      it "is invalid if guidance markdown contains unsupported tags" do
        error_message = I18n.t("activerecord.errors.models.draft_question.attributes.guidance_markdown.unsupported_markdown_syntax")
        draft_question.guidance_markdown = "# Heading level 1"
        expect(draft_question).to be_invalid
        expect(draft_question.errors.full_messages_for(:guidance_markdown)).to include("Guidance markdown #{error_message}")
      end

      it "is invalid if guidance markdown is over 5000 characters" do
        error_message = I18n.t("activerecord.errors.models.draft_question.attributes.guidance_markdown.too_long")
        draft_question.guidance_markdown = "A" * 5001
        expect(draft_question).to be_invalid
        expect(draft_question.errors.full_messages_for(:guidance_markdown)).to include("Guidance markdown #{error_message}")
      end

      it "is valid if page_heading is less than 250 characters" do
        draft_question.page_heading = "A" * 10
        expect(draft_question).to be_valid
      end

      it "is valid if page_heading is equal to 250 characters" do
        draft_question.page_heading = "A" * 250
        expect(draft_question).to be_valid
      end

      it "is invalid if page heading is more than 250 characters" do
        draft_question.page_heading = "A" * 251
        expect(draft_question).not_to be_valid
        error_message = I18n.t("activerecord.errors.models.draft_question.attributes.page_heading.too_long", count: 250)
        expect(draft_question.errors.full_messages_for(:page_heading)).to include("Page heading #{error_message}")
      end
    end
  end
end
