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

  it "is invalid if the user and group are not in the same organisation" do
    org1 = create :organisation, id: 1, slug: "test-org"
    org2 = create :organisation, id: 2, slug: "ministry-of-testing"
    user = create :user, organisation: org1
    group = create :group, organisation: org2
    membership = build(:membership, user:, group:)
    expect(membership).not_to be_valid
  end

  it "is invalid if the user is already a member of the group" do
    user = create :user
    group = create :group
    create(:membership, user:, group:)
    membership = build(:membership, user:, group:)
    expect(membership).not_to be_valid
  end

  it "raises a DB error if the user is already a member of the group" do
    user = create :user
    group = create :group
    create(:membership, user:, group:)
    membership = build(:membership, user:, group:)
    expect { membership.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
