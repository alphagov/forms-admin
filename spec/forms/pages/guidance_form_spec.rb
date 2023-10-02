require "rails_helper"

RSpec.describe Pages::GuidanceForm, type: :model do
  let(:guidance_form) { described_class.new(page_heading:, guidance_markdown:, draft_question:) }
  let(:draft_question) { build :draft_question, user: }
  let(:user) { build :user }
  let(:page_heading) { "New guidance heading" }
  let(:guidance_markdown) { "## Level heading 2" }

  describe "validations" do
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
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      allow(guidance_form).to receive(:invalid?).and_return(true)
      expect(guidance_form.submit).to eq false
    end

    context "when page_heading and guidance_markdown are valid" do
      let(:page_heading) { "My new page heading" }
      let(:guidance_markdown) { "Extra guidance needed to answer this question" }

      it "sets draft question with the page heading in it" do
        guidance_form.submit
        expect(draft_question.page_heading).to eq page_heading
      end

      it "sets draft question with the guidance_markdown in it" do
        guidance_form.submit
        expect(draft_question.guidance_markdown).to eq guidance_markdown
      end
    end
  end
end
