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
  end
end
