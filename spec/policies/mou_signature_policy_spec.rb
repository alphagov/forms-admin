require "rails_helper"

describe MouSignaturePolicy do
  subject(:policy) { described_class.new(user, :mouSignature) }

  let(:user) { build :super_admin_user }

  context "with super admin" do
    it { is_expected.to permit_actions(%i[can_manage_mous]) }
  end

  (User.roles.keys - %w[super_admin]).each do |role|
    context "with #{role}" do
      let(:user) { build :user, role: }

      it { is_expected.to forbid_actions(%i[can_manage_mous]) }
    end
  end
end
