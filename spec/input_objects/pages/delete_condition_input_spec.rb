require "rails_helper"

RSpec.describe Pages::DeleteConditionInput, type: :model do
  let(:delete_condition_input) { described_class.new(form:, page:, record: condition) }
  let(:form) { build :form, :ready_for_routing, id: 1 }
  let(:pages) { form.pages }
  let(:page) { pages.second }
  let(:goto_page) { pages.last }
  let(:answer_value) { "Wales" }
  let(:goto_page_id) { goto_page.id }
  let(:skip_to_end) { false }
  let(:condition) { build :condition, id: 2, form_id: form.id, page_id: page.id, routing_page_id: page.id, check_page_id: page.id, answer_value:, goto_page_id:, skip_to_end: }

  describe "validations" do
    it "is invalid if confirm is nil" do
      delete_condition_input.confirm = nil
      expect(delete_condition_input).to be_invalid
      expect(delete_condition_input.errors.full_messages_for(:confirm)).to include("Confirm Select yes if you want to delete this route")
    end
  end

  describe "#delete" do
    context "when validation pass" do
      it "destroys the condition" do
        allow(ConditionRepository).to receive(:destroy).and_return(true)
        delete_condition_input.confirm = "yes"

        delete_condition_input.submit
        expect(ConditionRepository).to have_received(:destroy)
      end
    end

    context "when validations fail" do
      it "returns false" do
        invalid_delete_condition_input = described_class.new
        expect(invalid_delete_condition_input.submit).to be false
        expect(invalid_delete_condition_input.errors.full_messages_for(:confirm)).to include(
          "Confirm Select yes if you want to delete this route",
        )
      end
    end
  end

  describe "#goto_page_question_text" do
    context "when there is a goto_page_id" do
      it "returns the question text for the given page" do
        result = delete_condition_input.goto_page_question_text
        expect(result).to eq(goto_page.question_text)
      end
    end

    context "when there is no goto_page_id" do
      let(:goto_page_id) { nil }
      let(:goto_page) { nil }

      it "returns nil" do
        result = delete_condition_input.goto_page_question_text
        expect(result).to be_nil
      end
    end

    context "when the goto page is set to check your answers" do
      let(:goto_page_id) { nil }
      let(:skip_to_end) { true }

      it "returns the check your answers translation" do
        expect(delete_condition_input.goto_page_question_text).to eq I18n.t("page_conditions.check_your_answers")
      end
    end
  end
end
