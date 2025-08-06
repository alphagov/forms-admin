require "rails_helper"

RSpec.describe Forms::GroupSelect, type: :model do
  let(:group_select) { described_class.new }

  describe "groups" do
    it "returns groups" do
      create_list(:group, 3)
      expect(group_select.groups.count).to eq(3)
    end

    it "returns an empty array when there are no groups" do
      expect(group_select.groups).to be_empty
    end
  end

  describe "to_partial_path" do
    it "returns the correct partial path" do
      expect(group_select.to_partial_path).to eq("input_objects/forms/group_select")
    end
  end
end
