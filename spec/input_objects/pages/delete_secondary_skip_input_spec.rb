require "rails_helper"

RSpec.describe Pages::DeleteSecondarySkipInput, type: :model do
  let(:delete_secondary_skip_input) { described_class.new(form:, page:, record: condition) }
  let(:form) { build :form, :ready_for_routing }
  let(:page) { form.pages.first }
  let(:condition) { build :condition, routing_page_id: page.id }

  describe "validations" do
    it "is invalid if confirm is nil" do
      delete_secondary_skip_input.confirm = nil
      expect(delete_secondary_skip_input).to be_invalid
      expect(delete_secondary_skip_input.errors.full_messages_for(:confirm)).to include("Confirm Select ‘Yes’ to delete route 2")
    end
  end

  describe "#submit" do
    context "when no confirm value is given" do
      it "returns false" do
        delete_secondary_skip_input.confirm = nil
        expect(delete_secondary_skip_input.submit).to be(false)
      end
    end

    context "when confirm is 'no'" do
      it "returns true" do
        delete_secondary_skip_input.confirm = "no"
        expect(delete_secondary_skip_input.submit).to be(true)
      end
    end

    context "when confirm is 'yes'" do
      before { allow(ConditionRepository).to receive(:destroy) }

      it "destroys the condition" do
        delete_secondary_skip_input.confirm = "yes"
        delete_secondary_skip_input.submit
        expect(ConditionRepository).to have_received(:destroy)
      end
    end
  end
end
