require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#link_to_runner" do
    context "with no live argument" do
      it "returns url to the form-runner's preview form" do
        expect(helper.link_to_runner("example.com", 2, "garden-form-slug")).to eq "example.com/preview-draft/2/garden-form-slug"
      end
    end

    context "with mode set to preview_draft" do
      it "returns url to the form-runner's preview form" do
        expect(helper.link_to_runner("example.com", 2, "garden-form-slug", mode: :preview_draft)).to eq "example.com/preview-draft/2/garden-form-slug"
      end
    end

    context "with mode set to preview_live" do
      it "returns url to the form-runner's live preview form" do
        expect(helper.link_to_runner("example.com", 2, "garden-form-slug", mode: :preview_live)).to eq "example.com/preview-live/2/garden-form-slug"
      end
    end

    context "with mode set to preview_archived" do
      it "returns url to the form-runner's archived preview form" do
        expect(helper.link_to_runner("example.com", 2, "garden-form-slug", mode: :preview_archived)).to eq "example.com/preview-archived/2/garden-form-slug"
      end
    end

    context "with mode set to live" do
      it "returns url to the form-runner's live form" do
        expect(helper.link_to_runner("example.com", 2, "garden-form-slug", mode: :live)).to eq "example.com/form/2/garden-form-slug"
      end
    end
  end

  describe "contact_url" do
    it "returns a link to the contact email address" do
      expect(helper.contact_url).to eq "mailto:govuk-forms-support@govuk.zendesk.com"
    end
  end

  describe "contact_link" do
    it "returns a link to the contact email address with default text" do
      expect(helper.contact_link).to eq '<a class="govuk-link" href="mailto:govuk-forms-support@govuk.zendesk.com">contact the GOV.UK Forms team</a>'
    end

    it "returns a link to the contact email address with custom text" do
      expect(helper.contact_link("test")).to eq '<a class="govuk-link" href="mailto:govuk-forms-support@govuk.zendesk.com">test</a>'
    end
  end

  describe "question_text_with_optional_suffix" do
    let(:page) { build :page }

    context "when show_optional_suffix? returns true" do
      before do
        allow(page).to receive(:show_optional_suffix?).and_return(true)
      end

      it "returns the title with the optional suffix" do
        expect(helper.question_text_with_optional_suffix(page)).to eq(I18n.t("pages.optional", question_text: page.question_text))
      end
    end

    context "when show_optional_suffix? returns false" do
      before do
        allow(page).to receive(:show_optional_suffix?).and_return(false)
      end

      it "returns the title with the optional suffix" do
        expect(helper.question_text_with_optional_suffix(page)).to eq(page.question_text)
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
        let(:input_type) { Pages::TextSettingsForm::INPUT_TYPES.sample }

        it "returns the answer subtype" do
          expect(helper.translation_key_for_answer_type(answer_type, answer_settings)).to eq input_type
        end
      end
    end

    context "with date answer type" do
      let(:answer_type) { "date" }
      let(:answer_settings) { OpenStruct.new(input_type:) }

      context "and 'input_type' set to a valid value" do
        let(:input_type) { Pages::DateSettingsForm::INPUT_TYPES.sample }

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

  describe "#govuk_assets_path" do
    it "returns the full node_modules asset path" do
      expect(helper.govuk_assets_path).to eq "/node_modules/govuk-frontend/dist/govuk/assets"
    end
  end

  describe "#user_role_options" do
    before do
      allow(I18n).to receive(:translate).with("users.roles.role1.name", any_args).and_return("name1")
      allow(I18n).to receive(:translate).with("users.roles.role1.description", any_args).and_return("description1")

      allow(I18n).to receive(:translate).with("users.roles.role2.name", any_args).and_return("name2")
      allow(I18n).to receive(:translate).with("users.roles.role2.description", any_args).and_return("description2")
    end

    it "returns the correct options" do
      expect(helper.user_role_options(%i[role1 role2])).to eq(
        [OpenStruct.new(label: "name1", value: :role1, description: "description1"),
         OpenStruct.new(label: "name2", value: :role2, description: "description2")],
      )
    end
  end

  describe "#sign_in_button" do
    context "when user is an e2e user and auth_provider is auth0" do
      before do
        allow(Settings).to receive(:auth_provider).and_return("auth0")
      end

      it "returns a string representing the sign-in button" do
        expect(helper.sign_in_button(is_e2e_user: true)).to include("e2e")
      end

      it "does not include e2e string when not the e2e user" do
        expect(helper.sign_in_button(is_e2e_user: false)).not_to include("e2e")
      end
    end

    context "when auth_provider is not auth0" do
      before do
        allow(Settings).to receive(:auth_provider).and_return("developer")
      end

      it "does not include e2e string when not the e2e user" do
        expect(helper.sign_in_button(is_e2e_user: true)).not_to include("e2e")
      end
    end
  end

  describe "#sign_up_button" do
    context "when user is an e2e user and auth_provider is auth0" do
      before do
        allow(Settings).to receive(:auth_provider).and_return("auth0")
      end

      it "returns a string representing the sign-up button" do
        expect(helper.sign_up_button(is_e2e_user: true)).to include("e2e", "signup")
      end

      context "when user is not an e2e user" do
        it "returns a string representing the sign-up button" do
          expect(helper.sign_up_button(is_e2e_user: false)).not_to include("e2e")
        end
      end
    end

    context "when auth_provider is not auth0" do
      before do
        allow(Settings).to receive(:auth_provider).and_return("developer")
      end

      it "returns a string representing the sign-up button" do
        expect(helper.sign_up_button(is_e2e_user: true)).not_to include("signup")
      end
    end
  end
end
