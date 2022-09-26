require "rails_helper"

RSpec.describe PreviewLinkComponent::View, type: :component do
  context "when the form has pages" do
    it "renders the link" do
      render_inline(described_class.new([{ id: 183, question_text: "What is your address?", question_short_name: nil, hint_text: "", answer_type: "address", next_page: nil }], "https://example.com"))
      expect(page).to have_link("Preview this form", href: "https://example.com")
    end
  end

  context "when the form has no pages" do
    it "does not render the link" do
      render_inline(described_class.new([], "https://example.com"))
      expect(page).not_to have_link("Preview this form", href: "https://example.com")
    end
  end
end
