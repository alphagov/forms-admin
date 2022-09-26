require "rails_helper"

RSpec.describe PreviewLinkComponent::View, type: :component do
  let(:preview_url) { "https://example.com"}

  context "when the form has pages" do
    it "renders the link" do
      render_inline(described_class.new([{ id: 183, question_text: "What is your address?", question_short_name: nil, hint_text: "", answer_type: "address", next_page: nil }], preview_url))
      expect(page).to have_link("Preview this form", href: preview_url)
    end
  end

  context "when the form has no pages" do
    it "does not render the link" do
      render_inline(described_class.new([], preview_url))
      expect(page).not_to have_link("Preview this form", href: preview_url)
    end
  end
end
