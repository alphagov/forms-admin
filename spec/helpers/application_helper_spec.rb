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
      it "returns url to the form-runner's live form" do
        expect(helper.link_to_runner("example.com", 2, "garden-form-slug", mode: :preview_live)).to eq "example.com/preview-live/2/garden-form-slug"
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

  describe "#govuk_assets_path" do
    it "returns the full node_modules asset path" do
      expect(helper.govuk_assets_path).to eq "/node_modules/govuk-frontend/govuk/assets"
    end
  end

  describe "#header_component_options" do
    let(:user) { build :user }
    let(:can_manage_users) { false }

    context "when a user is not signed in" do
      let(:user) { nil }

      it "returns options" do
        expect(helper.header_component_options(user:, can_manage_users:)).to eq({ is_signed_in: false, list_of_users_path: nil, signout_link: nil, user_name: nil, user_profile_link: nil })
      end
    end

    context "when a user is signed in" do
      it "returns the following options" do
        expect(helper.header_component_options(user:, can_manage_users:)).to eq({ is_signed_in: true,
                                                                                  list_of_users_path: nil,
                                                                                  signout_link: "/auth/gds/sign_out",
                                                                                  user_name: user.name,
                                                                                  user_profile_link: "http://signon.dev.gov.uk" })
      end

      context "when can manager users" do
        let(:can_manage_users) { true }

        it "returns the following options" do
          expect(helper.header_component_options(user:, can_manage_users:)).to eq({ is_signed_in: true,
                                                                                    list_of_users_path: users_path,
                                                                                    signout_link: "/auth/gds/sign_out",
                                                                                    user_name: user.name,
                                                                                    user_profile_link: "http://signon.dev.gov.uk" })
        end
      end

      context "when http basic auth is enabled" do
        it "returns the following options" do
          basic_auth_double = object_double("basic_auth_double", enabled: true)
          allow(Settings).to receive(:basic_auth).and_return(basic_auth_double)

          expect(helper.header_component_options(user:, can_manage_users:)).to eq({ is_signed_in: true,
                                                                                    list_of_users_path: nil,
                                                                                    signout_link: nil,
                                                                                    user_name: user.name,
                                                                                    user_profile_link: nil })
        end
      end
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
end
