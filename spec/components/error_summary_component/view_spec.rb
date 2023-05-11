require "rails_helper"

RSpec.describe ErrorSummaryComponent::View, type: :component do
  context "when given an empty array of errors" do
    before do
      render_inline(described_class.new(errors: []))
    end

    it "does not render the component" do
      expect(page).not_to have_selector("*")
    end
  end

  context "when given an array of errors" do
    let(:error1) { OpenStruct.new(message: "You have an error", link: "https://example.gov.uk/error1") }
    let(:error2) { OpenStruct.new(message: "You have another error", link: "https://example.gov.uk/error2") }

    before do
      render_inline(described_class.new(errors: [error1, error2]))
    end

    it "renders the heading" do
      expect(page).to have_text(I18n.t("error_summary.heading"))
    end

    it "renders the error links" do
      expect(page).to have_link(error1.message, href: error1.link)
      expect(page).to have_link(error2.message, href: error2.link)
    end
  end
end
