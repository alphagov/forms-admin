require "rails_helper"

describe ConditionRepository do
  let(:form) { create(:form_record) }
  let(:routing_page) { create(:page_record, form:) }
  let(:goto_page) { create(:page_record, form:) }

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
