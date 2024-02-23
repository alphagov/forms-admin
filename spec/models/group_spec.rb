require "rails_helper"

RSpec.describe Group, type: :model do
  it "has a valid factory" do
    expect(build(:group)).to be_valid
  end

  describe "validations" do
    it "is invalid without a name" do
      group = build :group, name: nil
      expect(group).not_to be_valid
    end

    it "is invalid without an organisation" do
      group = build :group, organisation: nil
      expect(group).not_to be_valid
    end
  end

  describe "before_create" do
    it "sets the external_id" do
      group = create :group
      expect(group.external_id).to be_present
    end
  end

  describe "#to_param" do
    it "returns the external_id" do
      group = create :group
      expect(group.to_param).to eq group.external_id
    end
  end

  describe "unique external_id" do
    it "two models with the same external_id cannot be saved to the DB" do
      group1 = create :group
      group2 = create :group

      group2.external_id = group1.external_id
      expect { group2.save! }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "associations" do
    it "destroys associated memberships" do
      group = create :group
      user = create :user
      added_by = create :user
      create(:membership, group:, user:, added_by:)

      expect { group.destroy }.to change(Membership, :count).by(-1)
    end
  end
end
