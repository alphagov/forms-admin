require "rails_helper"

describe UserUpgradeRequestService do
  subject(:user_upgrade_request_service) do
    described_class.new(user)
  end

  let(:user) { build :user, :with_trial_role, id: 1 }

  describe "#request_upgrade" do
    before do
      allow(EventLogger).to receive(:log)

      user_upgrade_request_service.request_upgrade
    end

    it "calls mailer with user email" do
      expect(ActionMailer::Base.deliveries.length).to eq 1
      mail = ActionMailer::Base.deliveries[0]
      expect(mail.to).to eq [user.email]
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
