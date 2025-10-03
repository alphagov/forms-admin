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
      subject(:delete_confirmation_input) { described_class.new(form:, page:) }

      let(:form) { create :form, :ready_for_routing }
      let(:pages) { form.pages }
      let(:page) { pages.first }
      let!(:primary_condition) { create :condition, routing_page: pages.first, check_page: pages.first, goto_page: pages.last }
      let!(:secondary_skip_condition) { create :condition, routing_page: pages.fourth, check_page: pages.first, goto_page: pages.last }
      let!(:other_condition) { create :condition, routing_page: pages.third, check_page: pages.third, skip_to_end: true }

      before do
        pages.each(&:reload)
      end

      it "returns true" do
        delete_confirmation_input.confirm = "no"
        expect(delete_confirmation_input.submit).to be true
      end

      context "when 'No' is selected" do
        it "does not delete any routes" do
          delete_confirmation_input.confirm = "no"

          expect {
            delete_confirmation_input.submit
          }.not_to change(Condition, :count)
        end
      end

      context "when 'Yes' is selected" do
        before do
          delete_confirmation_input.confirm = "yes"
          delete_confirmation_input.submit
        end

        it "deletes the primary route" do
          expect(Condition.exists?(primary_condition.id)).to be false
        end

        it "deletes the secondary skip route" do
          expect(Condition.exists?(secondary_skip_condition.id)).to be false
        end

        it "does not delete an unrelated route" do
          expect(Condition.exists?(other_condition.id)).to be true
        end
      end
    end
  end
end
