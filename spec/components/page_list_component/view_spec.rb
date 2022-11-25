require "rails_helper"

RSpec.describe PageListComponent::View, type: :component do
  let(:pages) { [] }

  context "when there are no pages" do
    it "is blank" do
      render_inline(described_class.new(pages: [], form_id: 0))
      expect(page).not_to have_selector("*")
    end
  end

  context "when the form has pages" do
    let(:pages) { [OpenStruct.new(id: 1, question_text: "Enter your name")] }

    it "renders question title" do
      render_inline(described_class.new(pages:, form_id: 0))
      expect(page).to have_content("Enter your name")
    end

    it "renders link" do
      render_inline(described_class.new(pages:, form_id: 0))
      expect(page).to have_link("Edit")
    end
  end
end
