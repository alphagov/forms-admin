require "rails_helper"

RSpec.describe Forms::WelshPageTranslationInput, type: :model do
  subject(:welsh_page_translation_input) { described_class.new(new_input_data) }

  let(:page) { create_page }

  let(:condition) do
    create :condition, routing_page: page, answer_value: "Yes",
                       exit_page_heading: "You are ineligible",
                       exit_page_markdown: "Sorry, you are ineligible for this service."
  end

  let(:another_condition) { create :condition, routing_page: page, answer_value: "Yes" }

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
      expect(welsh_page_translation_input.submit).to be true
    end

    it "updates the page's welsh attributes with the new values" do
      welsh_page_translation_input.submit
      page.reload

      expect(page.reload.question_text_cy).to eq(new_input_data[:question_text_cy])
      expect(page.reload.hint_text_cy).to eq(new_input_data[:hint_text_cy])
      expect(page.reload.page_heading_cy).to eq(new_input_data[:page_heading_cy])
      expect(page.reload.guidance_markdown_cy).to eq(new_input_data[:guidance_markdown_cy])
    end

    it "does not update any non-welsh attributes" do
      english_value_before = page.question_text
      welsh_page_translation_input.submit
      expect(page.question_text).to eq(english_value_before)
    end

    context "when the page has no hint text" do
      let(:page) { create_page(hint_text: nil) }

      it "clears the Welsh hint text" do
        welsh_page_translation_input.submit
        expect(page.reload.hint_text_cy).to be_nil
      end
    end

    context "when the page has no page heading or guidance markdown" do
      let(:page) { create_page(page_heading: nil, guidance_markdown: nil) }

      it "clears the Welsh page heading" do
        welsh_page_translation_input.submit
        expect(page.page_heading_cy).to be_nil
        expect(page.guidance_markdown_cy).to be_nil
      end
    end

    context "when the form includes condition translation objects" do
      let(:condition_translation) { Forms::WelshConditionTranslationInput.new(id: condition.id, answer_value_cy: "Ydw", exit_page_heading_cy: "Nid ydych yn gymwys", exit_page_markdown_cy: "Mae'n ddrwg gennym, nid ydych yn gymwys ar gyfer y gwasanaeth hwn.") }
      let(:another_condition_translation) { Forms::WelshConditionTranslationInput.new(id: another_condition.id, answer_value_cy: "Nac ydw") }

      let(:new_input_data) { super().merge(condition_translations: [condition_translation, another_condition_translation]) }

      it "submits the data on the condition translation objects" do
        welsh_page_translation_input.submit

        expect(condition.reload.answer_value_cy).to eq("Ydw")
        expect(condition.reload.exit_page_heading_cy).to eq("Nid ydych yn gymwys")
        expect(condition.reload.exit_page_markdown_cy).to eq("Mae'n ddrwg gennym, nid ydych yn gymwys ar gyfer y gwasanaeth hwn.")
        expect(another_condition.reload.answer_value_cy).to eq("Nac ydw")
      end
    end
  end

  describe "#assign_page_values" do
    it "loads the existing welsh attributes from the page" do
      welsh_page_translation_input = described_class.new(id: page.id)
      welsh_page_translation_input.assign_page_values

      expect(welsh_page_translation_input.question_text_cy).to eq(page.question_text_cy)
      expect(welsh_page_translation_input.hint_text_cy).to eq(page.hint_text_cy)
      expect(welsh_page_translation_input.page_heading_cy).to eq(page.page_heading_cy)
      expect(welsh_page_translation_input.guidance_markdown_cy).to eq(page.guidance_markdown_cy)
    end
  end

  describe "#page_has_hint_text?" do
    context "when the page has hint_text" do
      let(:page) { create_page(hint_text: "Choose 'Yes' if you already have a valid licence.") }

      it "returns true" do
        expect(welsh_page_translation_input.page_has_hint_text?).to be true
      end
    end

    context "when the page has no hint_text" do
      let(:page) { create_page(hint_text: nil) }

      it "returns false" do
        expect(welsh_page_translation_input.page_has_hint_text?).to be false
      end
    end
  end

  describe "#page_has_page_heading_and_guidance_markdown?" do
    context "when the page has a page_heading" do
      let(:page) { create_page(page_heading: "Licencing") }

      it "returns true" do
        expect(welsh_page_translation_input.page_has_page_heading_and_guidance_markdown?).to be true
      end
    end

    context "when the page has no page_heading and guidance_markdown" do
      let(:page) { create_page(page_heading: nil, guidance_markdown: nil) }

      it "returns false" do
        expect(welsh_page_translation_input.page_has_page_heading_and_guidance_markdown?).to be false
      end
    end
  end
end
