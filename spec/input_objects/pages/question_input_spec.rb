require "rails_helper"

RSpec.describe Pages::QuestionInput, type: :model do
  let(:form) { create :form }
  let(:answer_settings) { { foo: "bar" } }
  let(:question_input) do
    build(:question_input, answer_type:, question_text:, draft_question:, is_optional:,
                           is_repeatable:, form_id: form.id, answer_settings:, page_heading: draft_question.page_heading,
                           guidance_markdown: draft_question.guidance_markdown)
  end
  let(:draft_question) { build :address_draft_question, :with_guidance, question_text:, form_id: form.id }
  let(:question_text) { "What is your full name?" }
  let(:is_optional) { "false" }
  let(:is_repeatable) { "false" }
  let(:answer_type) { draft_question.answer_type }

  it "has a valid factory" do
    expect(build(:question_input)).to be_valid
  end

  describe "validations" do
    describe "#question_text" do
      it "is invalid given nil question text" do
        error_message = I18n.t("activemodel.errors.models.pages/question_input.attributes.question_text.blank")
        question_input.question_text = nil
        expect(question_input).to be_invalid
        expect(question_input.errors[:question_text]).to include(error_message)
      end

      it "is invalid given empty string question text" do
        error_message = I18n.t("activemodel.errors.models.pages/question_input.attributes.question_text.blank")
        question_input.question_text = ""
        expect(question_input).to be_invalid
        expect(question_input.errors[:question_text]).to include(error_message)
      end

      it "is valid if question text below 250 characters" do
        expect(question_input).to be_valid
      end

      context "when question text is 250 characters" do
        let(:question_text) { "A" * 250 }

        it "is valid" do
          expect(question_input).to be_valid
        end
      end

      context "when question text more than 250 characters" do
        let(:question_text) { "A" * 251 }

        it "is invalid" do
          expect(question_input).to be_invalid
        end

        it "has an error message" do
          question_input.valid?
          expect(question_input.errors[:question_text]).to include("Question text must be 250 characters or less")
        end
      end

      context "when the answer type is file" do
        let(:answer_type) { "file" }

        context "when question text is blank" do
          let(:question_text) { "" }

          it "has a file answer type specific error message" do
            expect(question_input).to be_invalid
            error_message = I18n.t("activemodel.errors.models.pages/question_input.attributes.question_text.blank_file")
            expect(question_input.errors[:question_text]).to include(error_message)
          end
        end

        context "when question text more than 250 characters" do
          let(:question_text) { "A" * 251 }

          it "has a file answer type specific error message" do
            expect(question_input).to be_invalid
            expect(question_input.errors[:question_text]).to include("Your text to ask for a file must be 250 characters or less")
          end
        end
      end
    end

    describe "#hint_text" do
      let(:question_input) { build :question_input, hint_text:, draft_question: }
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
      let(:question_input) { build :question_input, is_optional:, draft_question: }

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
      let(:question_input) { build :question_input, is_repeatable:, draft_question: }

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

    context "when not given a draft_question" do
      let(:question_input) do
        build(:question_input, answer_type:, question_text:, draft_question: nil, is_optional:,
                               is_repeatable:, form_id: form.id)
      end

      it "is invalid" do
        expect(question_input).to be_invalid
      end
    end

    describe "selection options" do
      let(:selection_options) { (1..31).to_a.map { |i| { name: i.to_s } } }
      let(:only_one_option) { "false" }
      let(:draft_question) { build :selection_draft_question, answer_settings: { selection_options:, only_one_option: }, form_id: form.id }

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
        let(:draft_question) { build :name_draft_question, answer_settings: { selection_options:, only_one_option: }, form_id: form.id }

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

  context "when the form has a Welsh translation" do
    let(:form) { create :form, available_languages: %w[en cy] }

    context "when the page has selection options" do
      let(:draft_question) { build :selection_draft_question, form_id: form.id }
      let(:answer_settings) { { selection_options: [{ name: "Option 1", value: "Option 1" }, { name: "Option 2", value: "Option 2" }] } }

      it "sets the welsh answer_settings to blank selection options" do
        question_input.question_text = "Choose an option"
        question_input.is_optional = "false"
        question_input.is_repeatable = "false"
        page = question_input.submit
        expect(page.answer_settings_cy.as_json).to eq({ "selection_options" => [{ "name" => "", "value" => "Option 1" }, { "name" => "", "value" => "Option 2" }] })
      end
    end
  end

  describe "#update_page" do
    let(:page) { create(:page, form:) }

    it "returns false if the form is invalid" do
      allow(question_input).to receive(:invalid?).and_return(true)
      expect(question_input.update_page(page)).to be false
    end

    context "when form is valid valid" do
      before do
        question_input.question_text = "How old are you?"
        question_input.hint_text = "As a number"
        question_input.is_optional = "false"
        question_input.is_repeatable = "true"
        question_input.update_page(page)
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

      it "updates the page attributes" do
        page.reload
        expect(page.question_text).to eq question_input.question_text
        expect(page.hint_text).to eq question_input.hint_text
        expect(page.is_optional.to_s).to eq question_input.is_optional
        expect(page.is_repeatable.to_s).to eq question_input.is_repeatable
        expect(page.answer_settings).to eq DataStruct.recursive_new(question_input.answer_settings)
        expect(page.page_heading).to eq question_input.page_heading
        expect(page.guidance_markdown).to eq question_input.guidance_markdown
        expect(page.answer_type).to eq question_input.answer_type
      end

      it "does not change the answer_settings_cy" do
        expect(page.answer_settings_cy).to be_nil
      end

      context "when the answer_settings has an empty hash for none_of_the_above_question" do
        let(:answer_settings) { { foo: "bar", none_of_the_above_question: {} } }

        it "removes the empty hash from the answer_settings" do
          expect(page.reload.answer_settings).to eq DataStruct.recursive_new({ "foo": "bar" })
        end
      end

      context "when the answer_settings has popolated none_of_the_above_question" do
        let(:answer_settings) { { foo: "bar", none_of_the_above_question: { "question_text": "Enter something" } } }

        it "keeps the populated none_of_the_above_question in the answer_settings" do
          expect(page.reload.answer_settings).to eq DataStruct.recursive_new({ "foo": "bar", "none_of_the_above_question": { "question_text": "Enter something" } })
        end
      end

      context "when the page has selection options and no Welsh translation" do
        let(:draft_question) { build :selection_draft_question, form_id: form.id }
        let(:answer_settings) { { selection_options: [{ name: "Option 1", value: "Option 1" }, { name: "Option 2", value: "Option 2" }] } }

        it "welsh answer_settings is nil" do
          expect(page.answer_settings_cy.as_json).to be_nil
        end
      end

      context "when the form has a Welsh translation and the page has selection options but no Welsh options yet" do
        let(:form) { create :form, available_languages: %w[en cy] }
        let(:draft_question) { build :selection_draft_question, form_id: form.id }
        let(:answer_settings) { { selection_options: [{ name: "Option 1", value: "Option 1" }, { name: "Option 2", value: "Option 2" }] } }

        it "adds the welsh answer_settings" do
          expect(page.answer_settings_cy.as_json).to eq({ "selection_options" => [{ "name" => "", "value" => "Option 1" }, { "name" => "", "value" => "Option 2" }] })
        end
      end

      context "when the form has a Welsh translation and the page has selection options and existing Welsh options" do
        let(:form) { create :form, available_languages: %w[en cy] }
        let(:draft_question) { build :selection_draft_question, form_id: form.id }
        let(:answer_settings) { { selection_options: [{ name: "Option 1", value: "Option 1" }, { name: "Option 2", value: "Option 2" }] } }
        let(:page) { create(:page, form:, answer_settings_cy: { selection_options: [{ name: "Yes", value: "Yes" }, { name: "No", value: "No" }] }) }

        it "keeps the welsh text but updates the new values" do
          expect(page.answer_settings_cy.as_json).to eq({ "selection_options" => [{ "name" => "Yes", "value" => "Option 1" }, { "name" => "No", "value" => "Option 2" }] })
        end
      end
    end
  end
end
