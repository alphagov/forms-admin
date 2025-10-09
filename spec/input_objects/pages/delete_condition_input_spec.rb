require "rails_helper"

RSpec.describe Pages::DeleteConditionInput, type: :model do
  let(:delete_condition_input) { described_class.new(form:, page:, record: condition) }
  let(:form) { create :form, :ready_for_routing }
  let(:pages) { form.pages }
  let(:page) { pages.second }
  let(:goto_page) { pages.last }
  let(:answer_value) { "Option 1" }
  let(:goto_page_id) { goto_page.id }
  let(:skip_to_end) { false }
  let(:condition) { create :condition, routing_page_id: page.id, check_page_id: page.id, answer_value:, goto_page_id:, skip_to_end: }

  describe "validations" do
    it "is invalid if confirm is nil" do
      delete_condition_input.confirm = nil
      expect(delete_condition_input).to be_invalid
      expect(delete_condition_input.errors.full_messages_for(:confirm)).to include("Confirm Select yes if you want to delete this route")
    end
  end

  describe "#submit" do
    context "when validation pass" do
      before do
        delete_condition_input.confirm = "yes"
      end

      it "destroys the condition" do
        expect {
          delete_condition_input.submit
        }.to change(Condition, :count).by(-1)
      end

      it "returns true" do
        expect(delete_condition_input.submit).to be true
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

  describe "#has_secondary_skip?" do
    context "when the condition does not have a secondary skip condition" do
      subject(:has_secondary_skip?) { delete_condition_input.has_secondary_skip? }

      it { is_expected.to be false }
    end

    context "when the condition has a secondary skip condition" do
      subject(:has_secondary_skip?) { delete_condition_input.has_secondary_skip? }

      let(:condition) do
        create :condition, routing_page_id: start_of_branches.id, check_page_id: start_of_branches.id, answer_value: "Wales", goto_page_id: start_of_second_branch.id
      end

      let(:start_of_branches) { pages.first }
      let(:end_of_first_branch) { pages.second }
      let(:start_of_second_branch) { pages.third }
      let(:end_of_branches) { pages.last }

      before do
        create :condition, routing_page_id: end_of_first_branch.id, check_page_id: start_of_branches.id, answer_value: nil, goto_page_id: end_of_branches.id
        pages.each(&:reload)
      end

      it { is_expected.to be true }
    end
  end
end
