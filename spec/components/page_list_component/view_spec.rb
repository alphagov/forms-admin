require "rails_helper"

RSpec.describe PageListComponent::View, type: :component do
  let(:pages) { [] }

  before do
    render_inline(described_class.new(pages:, form_id: 0))
  end

  context "when there are no pages" do
    it "is blank" do
      expect(page).not_to have_selector("*")
    end
  end

  context "when the form has a single page" do
    let(:pages) { [OpenStruct.new(id: 1, question_text: "Enter your name?")] }

    it "renders the question number" do
      expect(page).to have_css("dt.govuk-summary-list__key", text: "1")
    end

    it "renders question title" do
      expect(page).to have_content("Enter your name")
    end

    it "renders link" do
      expect(page).to have_link("Edit")
    end

    context "when re-ordering pages feature is enabled", feature_reorder_pages: true do
      it "does not have re-ordering buttons" do
        expect(page).not_to have_button("Move up")
        expect(page).not_to have_button("Move down")
      end
    end
  end

  context "when the form has multiple pages" do
    let(:pages) { [OpenStruct.new(id: 1, question_text: "Enter your name?"), OpenStruct.new(id: 2, question_text: "What is you pet's name?")] }

    it "renders the question numbers" do
      expect(page).to have_css("dt.govuk-summary-list__key", text: "1")
      expect(page).to have_css("dt.govuk-summary-list__key", text: "2")
    end

    context "when re-ordering pages feature is enabled", feature_reorder_pages: true do
      it "renders a move up link" do
        expect(page).to have_button("Move up")
      end

      it "renders a move down link" do
        expect(page).to have_button("Move down")
      end
    end
  end
end
