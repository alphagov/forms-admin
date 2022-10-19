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
end
