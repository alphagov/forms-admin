require "rails_helper"

describe GroupFormPolicy do
  subject(:policy) { described_class.new(user, group_form) }

  let(:group) { build :group, id: 1 }
  let(:group_form) { GroupForm.new(group:) }

  context "when user can access group" do
    let(:user) { build :user, groups: [group] }

    it { is_expected.to permit_all_actions }
  end

  context "when user cannot access group" do
    let(:user) { build :user }

    it { is_expected.to forbid_all_actions }
  end
end
