require "rails_helper"

describe Account::TermsOfUseInput do
  include ActiveSupport::Testing::TimeHelpers

  subject(:terms_of_use_input) { described_class.new(user:) }

  let(:user) { create(:user) }

  describe "validations" do
    it "is valid when the user has agreed" do
      terms_of_use_input.agreed = true
      expect(terms_of_use_input).to be_valid
    end

    it "is invalid when the user has not agreed" do
      terms_of_use_input.agreed = false

      expect(terms_of_use_input).not_to be_valid
      expect(terms_of_use_input.errors[:agreed]).to include(I18n.t("activemodel.errors.models.account/terms_of_use_input.attributes.agreed.accepted"))
    end
  end

  describe "#submit" do
    context "with valid attributes" do
      before do
        terms_of_use_input.agreed = true
      end

      it "updates the terms agreed at timestamp" do
        current_time = Time.zone.now.midnight
        travel_to current_time

        expect { terms_of_use_input.submit }.to change { user.reload.terms_agreed_at }.to(current_time)
      end

      it "returns true" do
        expect(terms_of_use_input.submit).to be true
      end
    end

    context "with invalid params" do
      before do
        terms_of_use_input.agreed = false
      end

      it "does not update the terms agreed at timestamp" do
        expect { terms_of_use_input.submit }.not_to(change { user.reload.terms_agreed_at })
      end

      it "returns false" do
        expect(terms_of_use_input.submit).to be false
      end
    end
  end
end
