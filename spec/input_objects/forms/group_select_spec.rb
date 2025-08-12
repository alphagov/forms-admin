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

  it "is valid when a group is present" do
    group_select.group = build(:group)

    expect(group_select).to be_valid
  end

  it "is invalid if group is blank" do
    group_select.group = nil
    expect(group_select).to be_invalid
    expect(group_select.errors[:group]).to include("Select the group you want to move this form to")
  end

  describe "to_partial_path" do
    it "returns the correct partial path" do
      expect(group_select.to_partial_path).to eq("input_objects/forms/group_select")
    end
  end
end
