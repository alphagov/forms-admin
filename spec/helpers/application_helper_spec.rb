require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#link_to_runner" do
    context "with no live argument" do
      it "returns url to the form-runner's preview form" do
        expect(helper.link_to_runner("example.com", 2, "garden-form-slug")).to eq "example.com/preview-form/2/garden-form-slug"
      end
    end

    context "with live set to false" do
      it "returns url to the form-runner's preview form" do
        expect(helper.link_to_runner("example.com", 2, "garden-form-slug", live: false)).to eq "example.com/preview-form/2/garden-form-slug"
      end
    end

    context "with live set to true" do
      it "returns url to the form-runner's live form" do
        expect(helper.link_to_runner("example.com", 2, "garden-form-slug", live: true)).to eq "example.com/form/2/garden-form-slug"
      end
    end
  end

  describe "contact_url" do
    it "returns a link to the contact email address" do
      expect(helper.contact_url).to eq "mailto:govuk-forms@digital.cabinet-office.gov.uk"
    end
  end

  describe "contact_link" do
    it "returns a link to the contact email address with default text" do
      expect(helper.contact_link).to eq '<a class="govuk-link" href="mailto:govuk-forms@digital.cabinet-office.gov.uk">Contact the GOV.UK Forms team</a>'
    end

    it "returns a link to the contact email address with custom text" do
      expect(helper.contact_link("test")).to eq '<a class="govuk-link" href="mailto:govuk-forms@digital.cabinet-office.gov.uk">test</a>'
    end
  end

  describe "question_text_with_optional_suffix" do
    context "with an optional question" do
      it "returns the title with the optional suffix" do
        page = OpenStruct.new(question_text: "What is your name?", is_optional: true)
        expect(helper.question_text_with_optional_suffix(page)).to eq(I18n.t("pages.optional", question_text: "What is your name?"))
      end
    end

    context "with a required question" do
      it "returns the title with the optional suffix" do
        page = OpenStruct.new(question_text: "What is your name?", is_optional: false)
        expect(helper.question_text_with_optional_suffix(page)).to eq("What is your name?")
      end
    end
  end

  describe "translation_key_for_answer_type" do
    let(:answer_type) { "email" }
    let(:answer_settings) { {} }

    context "with a non-selection answer type" do
      it "returns the answer type" do
        expect(helper.translation_key_for_answer_type(answer_type, answer_settings)).to eq "email"
      end
    end

    context "with selection answer type" do
      let(:answer_type) { "selection" }

      context "and 'only_one_option' set to 'true'" do
        let(:answer_settings) { OpenStruct.new(only_one_option: "true") }

        it "returns the answer subtype" do
          expect(helper.translation_key_for_answer_type(answer_type, answer_settings)).to eq "radio"
        end
      end

      context "and 'only_one_option' set to 'false'" do
        let(:answer_settings) { OpenStruct.new(only_one_option: false) }

        it "returns the answer subtype" do
          expect(helper.translation_key_for_answer_type(answer_type, answer_settings)).to eq "checkbox"
        end
      end
    end

    context "with text answer type" do
      let(:answer_type) { "text" }
      let(:answer_settings) { OpenStruct.new(input_type:) }

      context "and 'input_type' set to a valid value" do
        let(:input_type) { Forms::TextSettingsForm::INPUT_TYPES.sample }

        it "returns the answer subtype" do
          expect(helper.translation_key_for_answer_type(answer_type, answer_settings)).to eq input_type
        end
      end
    end

    context "with date answer type" do
      let(:answer_type) { "date" }
      let(:answer_settings) { OpenStruct.new(input_type:) }

      context "and 'input_type' set to a valid value" do
        let(:input_type) { Forms::DateSettingsForm::INPUT_TYPES.sample }

        it "returns the answer subtype" do
          expect(helper.translation_key_for_answer_type(answer_type, answer_settings)).to eq input_type
        end
      end
    end
  end

  describe "hint_for_edit_page_field" do
    context "with an answer type that has custom text" do
      let(:answer_type) { "email" }
      let(:answer_settings) { {} }

      it "returns the custom hint text for the answer type" do
        expect(helper.hint_for_edit_page_field("question_text", answer_type, answer_settings)).to eq(I18n.t("helpers.hint.page.question_text.email"))
      end
    end

    context "with an answer type that does not have custom text" do
      let(:answer_type) { "some_random_string" }
      let(:answer_settings) { {} }

      it "returns the default hint text" do
        expect(helper.hint_for_edit_page_field("hint_text", answer_type, answer_settings)).to eq(I18n.t("helpers.hint.page.hint_text.default"))
      end
    end
  end
end
