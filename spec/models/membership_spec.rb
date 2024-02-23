require "rails_helper"

RSpec.describe Membership, type: :model do
  it "has a valid factory" do
    expect(build(:membership)).to be_valid
  end

  it "is invalid without a user" do
    membership = build :membership, user: nil
    expect(membership).not_to be_valid
  end

  it "is invalid without a group" do
    membership = build :membership, group: nil
    expect(membership).not_to be_valid
  end

  it "is invalid without an added_by" do
    membership = build :membership, added_by: nil
    expect(membership).not_to be_valid
  end
end
