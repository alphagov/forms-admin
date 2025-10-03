require "rails_helper"

describe ConditionRepository do
  let(:form) { create(:form_record) }
  let(:routing_page) { create(:page_record, form:) }
  let(:goto_page) { create(:page_record, form:) }

  describe "#find" do
    let(:condition) { create(:condition_record, routing_page_id: routing_page.id, check_page_id: routing_page.id, goto_page_id: goto_page.id) }

    it "returns the condition" do
      expect(described_class.find(condition_id: condition.id, page_id: routing_page.id)).to eq(condition)
    end

    context "when given a page_id that the condition doesn't belong to" do
      let(:page_id) { "non-existent-id" }

      it "raises a RecordNotFound error" do
        expect {
          described_class.find(condition_id: condition.id, page_id: page_id)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#save!" do
    let(:condition) { create(:condition_record, skip_to_end: false, routing_page_id: routing_page.id, answer_value: "database condition") }

    it "saves the condition to the database" do
      condition.skip_to_end = true

      expect {
        described_class.save!(condition)
      }.to change { Condition.find(condition.id).skip_to_end }.to(true)
    end

    it "returns the database condition" do
      expect(described_class.save!(condition)).to eq(condition)
    end

    context "when the form question section is complete" do
      let(:form) { create(:form_record, question_section_completed: true) }

      it "updates the form to mark the question section as incomplete" do
        expect {
          described_class.save!(condition)
        }.to change { Form.find(form.id).question_section_completed }.to(false)
      end
    end
  end

  describe "#destroy" do
    let!(:condition) { create(:condition_record, routing_page_id: routing_page.id) }

    it "removes the condition from the database" do
      expect {
        described_class.destroy(condition)
      }.to change(Condition, :count).by(-1)
    end

    it "returns a condition record" do
      expect(described_class.destroy(condition)).to be_a(Condition)
    end

    context "when the form question section is complete" do
      let(:form) { create(:form_record, question_section_completed: true) }

      it "updates the form to mark the question section as incomplete" do
        expect {
          described_class.destroy(condition)
        }.to change { Form.find(form.id).question_section_completed }.to(false)
      end
    end

    it "returns the deleted condition" do
      expect(described_class.destroy(condition)).to eq condition
    end
  end
end
