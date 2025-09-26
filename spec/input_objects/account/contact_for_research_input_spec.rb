require "rails_helper"

describe Account::ContactForResearchInput do
  include ActiveSupport::Testing::TimeHelpers

  subject(:contact_for_research_input) { described_class.new(user:) }

  let(:user) { create(:user) }

  describe "#submit" do
    context "with valid attributes" do
      before do
        contact_for_research_input.research_contact_status = "consented"
      end

      it "updates the user research opted in at timestamp" do
        current_time = Time.zone.now.midnight
        travel_to current_time

        expect { contact_for_research_input.submit }.to change { user.reload.user_research_opted_in_at }.to(current_time)
      end

      it "returns true" do
        expect(contact_for_research_input.submit).to be true
      end
    end
  end
end
