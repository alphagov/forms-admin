require "rails_helper"

RSpec.describe GroupPolicy do
  subject(:policy) { described_class.new(user, group) }

  let(:user) { build :editor_user }
  let(:group) { build :group, organisation_id: user.organisation_id }

  context "when user is super_admin" do
    let(:user) { build :super_admin_user }

    it { is_expected.to permit_actions(%i[create edit show destroy update index]) }

    context "and user belongs to a different organisation than the group" do
      let(:group) { build :group, organisation_id: user.organisation_id + 1 }

      it "allows show, edit, update or destroy" do
        expect(policy).to permit_actions(%i[show edit update destroy])
      end
    end

    it "scope resolves to all groups" do
      expect(GroupPolicy::Scope.new(user, Group).resolve).to eq(Group.all)
    end
  end

  context "when user is editor" do
    it { is_expected.to permit_actions(%i[create edit show destroy update index]) }

    context "and user belongs to a different organisation than the group" do
      let(:group) { build :group, organisation_id: user.organisation_id + 1 }

      it "does not allow show, edit, update or destroy" do
        expect(policy).to forbid_actions(%i[show edit update destroy])
      end
    end

    it "scope resolves to groups for user in same organisation" do
      expect(GroupPolicy::Scope.new(user, Group).resolve).to eq(Group.for_user(user))
    end
  end
end
