require "rails_helper"

RSpec.describe Pages::GuidanceForm, type: :model do
  let(:guidance_form) { build :guidance_form, page_heading:, guidance_markdown:, draft_question: }
  let(:draft_question) { build :draft_question, page_heading:, guidance_markdown: }
  let(:page_heading) { "New guidance heading" }
  let(:guidance_markdown) { "## Level heading 2" }

  it "has a valid factory" do
    expect(guidance_form).to be_valid
  end

  describe "validations" do
    it_behaves_like "a markdown field with headings allowed" do
      let(:model) { guidance_form }
      let(:attribute) { :guidance_markdown }
    end

    it "is invalid if page heading is nil" do
      error_message = I18n.t("activemodel.errors.models.pages/guidance_form.attributes.page_heading.blank")
      guidance_form.page_heading = nil
      expect(guidance_form).to be_invalid
      expect(guidance_form.errors.full_messages_for(:page_heading)).to include("Page heading #{error_message}")
    end

    it "is invalid if guidance_markdown is nil" do
      error_message = I18n.t("activemodel.errors.models.pages/guidance_form.attributes.guidance_markdown.blank")
      guidance_form.guidance_markdown = nil
      expect(guidance_form).to be_invalid
      expect(guidance_form.errors.full_messages_for(:guidance_markdown)).to include("Guidance markdown #{error_message}")
    end

    context "when page_heading and guidance_markdown are not blank" do
      let(:page_heading) { "New guidance heading" }
      let(:guidance_markdown) { "## Level heading 2" }

      it "is valid" do
        expect(guidance_form).to be_valid
      end
    end

    it "is invalid if guidance markdown contains unsupported tags" do
      error_message = I18n.t("activemodel.errors.models.pages/guidance_form.attributes.guidance_markdown.unsupported_markdown_syntax")
      guidance_form.guidance_markdown = "# Heading level 1"
      expect(guidance_form).to be_invalid
      expect(guidance_form.errors.full_messages_for(:guidance_markdown)).to include("Guidance markdown #{error_message}")
    end

    it "is invalid if guidance markdown is over 5000 characters" do
      error_message = I18n.t("activemodel.errors.models.pages/guidance_form.attributes.guidance_markdown.too_long")
      guidance_form.guidance_markdown = "A" * 5001
      expect(guidance_form).to be_invalid
      expect(guidance_form.errors.full_messages_for(:guidance_markdown)).to include("Guidance markdown #{error_message}")
    end

    ["A" * 10, "A" * 250].each do |question_text|
      it "is valid if page_heading is less than or equal to 250 characters" do
        guidance_form.page_heading = question_text
        expect(guidance_form).to be_valid
      end
    end

    it "is invalid if page heading is more than 250 characters" do
      guidance_form.page_heading = "A" * 251
      expect(guidance_form).not_to be_valid
      error_message = I18n.t("activemodel.errors.models.pages/guidance_form.attributes.page_heading.too_long", count: 250)
      expect(guidance_form.errors.full_messages_for(:page_heading)).to include("Page heading #{error_message}")
    end

    context "when not given a draft_question" do
      let(:draft_question) { nil }

      it "is invalid" do
        expect(guidance_form).to be_invalid
      end
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      allow(guidance_form).to receive(:invalid?).and_return(true)
      expect(guidance_form.submit).to eq false
    end

    context "when page_heading and guidance_markdown are valid" do
      let(:page_heading) { "My new page heading" }
      let(:guidance_markdown) { "Extra guidance needed to answer this question" }

      it "sets draft_question page_heading and guidance_markdown" do
        guidance_form.page_heading = "This is my heading"
        guidance_form.guidance_markdown = "This is markdown guidance"
        guidance_form.submit

        expect(guidance_form.draft_question.page_heading).to eq("This is my heading")
        expect(guidance_form.draft_question.guidance_markdown).to eq("This is markdown guidance")
      end
    end
  end
end
