require "rails_helper"

RSpec.describe Pages::TypeOfAnswerInput, type: :model do
  let(:type_of_answer_input) { build :type_of_answer_input, draft_question:, current_form: }
  let(:draft_question) { build :draft_question, form_id: current_form.id }
  let(:current_form) { create :form }

  it "has a valid factory" do
    expect(type_of_answer_input).to be_valid
  end

  describe "validations" do
    it "is invalid if not given a type of answer" do
      type_of_answer_input.answer_type = nil
      expect(type_of_answer_input).to be_invalid
    end

    it "is invalid given an empty string answer_type" do
      type_of_answer_input.answer_type = ""
      expect(type_of_answer_input).to be_invalid
      expect(type_of_answer_input.errors.full_messages_for(:answer_type)).to include("Answer type Select the type of answer you need")
    end

    it "is valid if answer type is a valid page answer type" do
      Page::ANSWER_TYPES.each do |answer_type|
        type_of_answer_input.answer_type = answer_type
        expect(type_of_answer_input).to be_valid "#{answer_type} is not a Page answer type"
      end
    end

    context "when not given a draft_question" do
      let(:draft_question) { nil }

      it "is invalid" do
        expect(type_of_answer_input).to be_invalid
      end
    end

    context "when the answer type is file" do
      before do
        type_of_answer_input.answer_type = "file"
      end

      context "when there are fewer than 4 existing file upload questions" do
        let(:pages) do
          pages = build_list :page, 3, answer_type: :file
          page_with_another_answer_type = build(:page, answer_type: :text)
          pages.push(page_with_another_answer_type)
        end
        let(:current_form) { create :form, pages: }

        it "is valid" do
          expect(type_of_answer_input).to be_valid
        end
      end

      context "when there are already 4 file upload questions" do
        let(:pages) { build_list :page, 4, answer_type: :file }
        let(:current_form) { create :form, pages: }

        it "is invalid" do
          expect(type_of_answer_input).to be_invalid
          expect(type_of_answer_input.errors[:answer_type]).to include "You cannot have more than 4 file upload questions in a form"
        end
      end

      context "when there are already more than 4 file upload questions" do
        let(:pages) { build_list :page, 5, answer_type: :file }
        let(:current_form) { create :form, pages: }

        it "is invalid" do
          expect(type_of_answer_input).to be_invalid
          expect(type_of_answer_input.errors[:answer_type]).to include "You cannot have more than 4 file upload questions in a form"
        end
      end
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      allow(type_of_answer_input).to receive(:invalid?).and_return(true)
      expect(type_of_answer_input.submit).to be_falsey
    end

    it "sets draft_question to the answer type" do
      type_of_answer_input.answer_type = "email"
      type_of_answer_input.submit
      expect(type_of_answer_input.draft_question.answer_type).to eq("email")
    end

    it "sets clears the answer_settings for the draft_question" do
      type_of_answer_input.answer_type = "email"
      type_of_answer_input.submit
      expect(type_of_answer_input.draft_question.answer_settings).to eq({})
    end

    context "when data is valid and answer_type_changed is false" do
      before do
        allow(type_of_answer_input).to receive_messages(invalid?: false, answer_type_changed?: false)
      end

      it "returns true" do
        expect(type_of_answer_input.submit).to be true
      end

      it "does not call save on draft_question" do
        expect(draft_question).not_to receive(:save!)
        type_of_answer_input.submit
      end
    end
  end
end
