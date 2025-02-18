require "rails_helper"

RSpec.describe Pages::Routes::DeleteConfirmationInput, type: :model do
  subject(:delete_confirmation_input) { described_class.new }

  describe "validations" do
    it "is invalid if confirm is nil" do
      delete_confirmation_input.confirm = nil
      expect(delete_confirmation_input).to be_invalid
      expect(delete_confirmation_input.errors.full_messages_for(:confirm)).to include("Confirm Select ‘Yes’ to delete this question’s routes")
    end

    it "is invalid if given invalid input" do
      delete_confirmation_input.confirm = "invalid"
      expect(delete_confirmation_input).to be_invalid
      expect(delete_confirmation_input.errors.full_messages_for(:confirm)).to include("Confirm is not included in the list")
    end

    it "is valid given valid input" do
      delete_confirmation_input.confirm = "yes"
      expect(delete_confirmation_input).to be_valid
    end
  end

  describe "#submit" do
    it "returns false if invalid" do
      delete_confirmation_input.confirm = "invalid"
      expect(delete_confirmation_input.submit).to be false
    end

    context "when valid" do
      subject(:delete_confirmation_input) { described_class.new(form:, page: form.pages[0]) }

      let(:form) { build :form, id: 1, pages: build_pages }

      def build_pages
        pages = build_list(:page, 5).each_with_index do |page, index|
          page.id = index
        end

        # primary route
        pages[0].routing_conditions = [ build(:condition, routing_page_id: 0, check_page_id: 0, goto_page_id: 4) ]
        # secondary skip
        pages[3].routing_conditions = [ build(:condition, routing_page_id: 3, check_page_id: 0, goto_page_id: 4) ]

        # unrelated condition
        pages[2].routing_conditions = [ build(:condition, routing_page_id: 2, check_page_id: 2, goto_page_id: 5) ]

        pages
      end

      before do
        allow(ConditionRepository).to receive(:destroy)
      end

      it "returns true" do
        delete_confirmation_input.confirm = "no"
        expect(delete_confirmation_input.submit).to be true
      end

      it "does not delete routes when not confirmed" do
        delete_confirmation_input.confirm = "no"

        delete_confirmation_input.submit

        expect(ConditionRepository).not_to have_received(:destroy)
      end

      it "deletes routes when confirmed" do
        delete_confirmation_input.confirm = "yes"
        delete_confirmation_input.submit

        expect(ConditionRepository).to have_received(:destroy).with(form.pages[0].routing_conditions.first)
        expect(ConditionRepository).to have_received(:destroy).with(form.pages[3].routing_conditions.first)
        expect(ConditionRepository).not_to have_received(:destroy).with(form.pages[2].routing_conditions.first)
      end
    end
  end
end
