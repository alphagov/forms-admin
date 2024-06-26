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
    let(:errors) { [OpenStruct.new(message: "You have an error", link: "https://example.gov.uk/error1"), OpenStruct.new(message: "You have another error", link: "https://example.gov.uk/error2")] }

    before do
      render_inline(described_class.new(errors:))
    end

    it "renders the heading" do
      expect(page).to have_text(I18n.t("error_summary.heading"))
    end

    it "renders the error links" do
      expect(page).to have_link(errors.first.message, href: errors.first.link)
      expect(page).to have_link(errors.second.message, href: errors.second.link)
    end
  end
end
