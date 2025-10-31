require "rails_helper"

RSpec.describe Forms::PageTranslationInput, type: :model do
  subject(:page_translation_input) { described_class.new(new_input_data) }

  let(:page) { create_page }

  let(:new_input_data) do
    {
      id: page.id,
      question_text_cy: "Ydych chi'n adnewyddu trwydded?",
      hint_text_cy: "Dewiswch 'Ydw' os oes gennych drwydded ddilys eisoes.",
      page_heading_cy: "Trwyddedu",
      guidance_markdown_cy: "Mae'r rhan hon o'r ffurflen yn ymwneud â thrwyddedu.",
    }
  end

  def create_page(attributes = {})
    default_attributes = {
      id: 1,
      question_text: "Are you renewing a licence?",
      hint_text: "Choose 'Yes' if you already have a valid licence.",
      page_heading: "Licencing",
      guidance_markdown: "This part of the form concerns licencing.",
      question_text_cy: "",
      hint_text_cy: "",
      page_heading_cy: "",
      guidance_markdown_cy: "",
    }
    create(:page, default_attributes.merge(attributes))
  end

  describe "#submit" do
    it "returns true" do
      expect(page_translation_input.submit).to be true
    end

    it "updates the page's welsh attributes with the new values" do
      page_translation_input.submit
      page.reload

      expect(page.question_text_cy).to eq(new_input_data[:question_text_cy])
      expect(page.hint_text_cy).to eq(new_input_data[:hint_text_cy])
      expect(page.page_heading_cy).to eq(new_input_data[:page_heading_cy])
      expect(page.guidance_markdown_cy).to eq(new_input_data[:guidance_markdown_cy])
    end

    it "does not update any non-welsh attributes" do
      english_value_before = page.question_text
      page_translation_input.submit
      expect(page.question_text).to eq(english_value_before)
    end

    context "when the page has no hint text" do
      let(:page) { create_page(hint_text: nil) }

      it "clears the Welsh hint text" do
        page_translation_input.submit
        expect(page.hint_text_cy).to be_nil
      end
    end

    context "when the page has no page heading or guidance markdown" do
      let(:page) { create_page(page_heading: nil, guidance_markdown: nil) }

      it "clears the Welsh page heading" do
        page_translation_input.submit
        expect(page.page_heading_cy).to be_nil
        expect(page.guidance_markdown_cy).to be_nil
      end
    end
  end

  describe "#assign_page_values" do
    it "loads the existing welsh attributes from the page" do
      page_translation_input = described_class.new(id: page.id)
      page_translation_input.assign_page_values

      expect(page_translation_input.question_text_cy).to eq(page.question_text_cy)
      expect(page_translation_input.hint_text_cy).to eq(page.hint_text_cy)
      expect(page_translation_input.page_heading_cy).to eq(page.page_heading_cy)
      expect(page_translation_input.guidance_markdown_cy).to eq(page.guidance_markdown_cy)
    end
  end
end
