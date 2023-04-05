require "rails_helper"

describe UserPolicy do
  subject(:policy) { described_class.new(user, records) }

  let(:user) { build :user, email: "joe.bloggs@digital.cabinet-office.gov.uk", organisation_slug: "gds" }
  let(:records) { build_list :user, 5 }

  context "when a user with a GDS email address" do
    it { is_expected.to permit_actions(%i[can_manage_user]) }
  end

  context "when a user with a non-GDS email address" do
    let(:user) { build :user, email: "joe.bloggs@digital.example.gov.uk", organisation_slug: "non-gds" }

    it { is_expected.to forbid_actions(%i[can_manage_user]) }
  end
end
