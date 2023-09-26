require "rails_helper"

describe UserUpgradeRequestService do
  subject(:user_upgrade_request_service) do
    described_class.new(user)
  end

  let(:user) { build :user, :with_trial_role, id: 1 }

  describe "#request_upgrade" do
    before do
      # prevent notify being called
      mailer = instance_double(ActionMailer::MessageDelivery)
      allow(mailer).to receive(:deliver_now)

      allow(UserUpgradeRequestMailer).to receive(:upgrade_request_email).and_return(mailer)

      allow(EventLogger).to receive(:log)

      user_upgrade_request_service.request_upgrade
    end

    it "calls mailer with user email" do
      expect(UserUpgradeRequestMailer).to have_received(:upgrade_request_email).with(user_email: user.email)
    end

    it "logs event" do
      expect(EventLogger).to have_received(:log).with(
        {
          "event": "upgrade_request",
          "user_id": user.id,
        },
      )
    end
  end
end
