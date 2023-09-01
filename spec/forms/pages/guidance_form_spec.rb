require "rails_helper"

RSpec.describe Pages::GuidanceForm, type: :model do
  let(:guidance_form) { described_class.new(page_heading:, guidance_markdown:) }
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

    context "when page_heading and guidance_markdown are blank" do
      let(:page_heading) { "New guidance heading" }
      let(:guidance_markdown) { "## Level heading 2" }

      it "is validate" do
        expect(guidance_form).to be_valid
      end
    end
  end

  describe "#submit" do
    let(:session_mock) { {} }

    it "returns false if the form is invalid" do
      allow(guidance_form).to receive(:invalid?).and_return(true)
      expect(guidance_form.submit(session_mock)).to eq false
    end

    context "when page_heading and guidance_markdown are valid" do
      let(:page_heading) { "My new page heading" }
      let(:guidance_markdown) { "Extra guidance needed to answer this question" }

      it "sets a session key called 'page' as a hash with the page heading in it" do
        guidance_form.submit(session_mock)
        expect(session_mock[:page][:page_heading]).to eq page_heading
      end

      it "sets a session key called 'page' as a hash with the guidance_markdown in it" do
        guidance_form.submit(session_mock)
        expect(session_mock[:page][:guidance_markdown]).to eq guidance_markdown
      end
    end
  end
end
