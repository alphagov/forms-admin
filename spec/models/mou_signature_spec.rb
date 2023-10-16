require "rails_helper"

RSpec.describe MouSignature, type: :model do
  let(:organisation) { create(:organisation) }
  let(:user) { create(:user, organisation:) }
  let(:mou_signature) do
    described_class.create!(
      user:,
      organisation:,
      agreed_at: Time.zone.now,
    )
  end

  it "setting user to nil triggers a DB constraint" do
    mou_signature.user = nil
    expect { mou_signature.save(validate: false) }.to raise_error(ActiveRecord::StatementInvalid).with_message(/null value in column "user_id"/)
    # expect { mou_signature.update_column(:user_id, nil) }.to raise_error(ActiveRecord::StatementInvalid).with_message(/null value in column "user_id"/)
  end

  it "creating more than one mou_signature for the same user and organisation triggers a DB constraint" do
    mou_signature
    expect {
      described_class.create!(
        user: mou_signature.user,
        organisation: mou_signature.organisation,
        agreed_at: Time.zone.now,
      )
    }.to raise_error(ActiveRecord::RecordNotUnique).with_message(/duplicate key value violates unique constraint "index_mou_signatures_on_user_id_and_organisation_id"/)
  end

  it "multiple users can create mou_signatures for the same organisation" do
    mou_signature
    another_user = create(:user, organisation: mou_signature.organisation)

    expect {
      described_class.create!(
        user: another_user,
        organisation: mou_signature.organisation,
        agreed_at: Time.zone.now,
      )
    }.not_to raise_error
  end

  it "creating more than one mou_signature for the same user with no organisation triggers a DB constraint" do
    described_class.create!(
      user: mou_signature.user,
      agreed_at: Time.zone.now,
    )

    expect {
      described_class.create!(
        user: mou_signature.user,
        agreed_at: Time.zone.now,
      )
    }.to raise_error(ActiveRecord::RecordNotUnique).with_message(/duplicate key value violates unique constraint "index_mou_signatures_on_user_id_unique_without_organisation_id"/)
  end

  it "multiple users can create mou_signatures with no organisation" do
    mou_signature.update_column(:organisation_id, nil)
    another_user = create(:user, organisation: mou_signature.organisation)

    expect {
      described_class.create!(
        user: another_user,
        organisation: nil,
        agreed_at: Time.zone.now,
      )
    }.not_to raise_error
  end
end
