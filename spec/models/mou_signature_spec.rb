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
end
