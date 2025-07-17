require "rails_helper"

RSpec.describe Condition, type: :model do
  subject(:condition) { described_class.new }

  it "has a valid factory" do
    condition = create :condition_record
    expect(condition).to be_valid
  end

  describe "destroying" do
    subject!(:condition) do
      create :condition_record
    end

    it "deletes the condition" do
      expect {
        condition.destroy
      }.to change(described_class, :count).by(-1)

      expect(condition).to be_destroyed
    end

    context "when there is another condition that depends on this one" do
      subject!(:condition) do
        described_class.create! check_page: start_of_branches, routing_page: start_of_branches, goto_page: start_of_second_branch
      end

      let!(:secondary_skip_condition) do
        described_class.create! check_page: start_of_branches, routing_page: end_of_first_branch, goto_page_id: end_of_branches
      end

      let(:start_of_branches) { create :page_record }
      let(:end_of_first_branch) { create :page_record }
      let(:start_of_second_branch) { create :page_record }
      let(:end_of_branches) { create :page_record }

      it "destroys the other condition" do
        condition.reload

        expect {
          condition.destroy!
        }.to change(described_class, :count).by(-2)

        expect(described_class).not_to exist(secondary_skip_condition.id)
      end
    end
  end
end
