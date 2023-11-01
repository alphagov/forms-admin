require "rails_helper"

RSpec.describe MouSignature, type: :model do
  let(:mou_signature) { build :mou_signature }

  it "has a valid factory" do
    expect(mou_signature).to be_valid
  end

  it "is invalid without a user" do
    error_message = I18n.t("errors.messages.required")

    mou_signature.user = nil
    expect(mou_signature).to be_invalid
    expect(mou_signature.errors[:user]).to include(error_message)
  end

  describe "#add_mou_signature_organisation" do
    let(:user) { create :user }
    let(:other_organisation) { create :organisation }
    let(:mou_signature) { create :mou_signature, user:, organisation: nil }
    let(:mou_signature_with_existing_org) { create :mou_signature, user:, organisation: other_organisation }

    it "updates organisation_id" do
      expect { described_class.add_mou_signature_organisation(user) }.to change { mou_signature.reload.organisation_id }.from(nil).to(user.organisation_id)
    end

    it "does not change MouSignature with org already set" do
      described_class.add_mou_signature_organisation(user)
      expect(mou_signature_with_existing_org.organisation_id).to eq(other_organisation.id)
    end
  end
end
