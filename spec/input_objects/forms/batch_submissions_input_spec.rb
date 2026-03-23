require "rails_helper"

RSpec.describe Forms::BatchSubmissionsInput, type: :model do
  describe "#submit" do
    subject(:input) { described_class.new(form:, send_daily_submission_batch: value) }

    let(:form) { create(:form, send_daily_submission_batch: false) }

    context "when enabling" do
      let(:value) { "1" }

      it "updates the form send_daily_submission_batch flag to true" do
        expect { input.submit }.to change { form.reload.send_daily_submission_batch }.to(true)
      end
    end

    context "when disabling" do
      let(:form) { create(:form, send_daily_submission_batch: true) }
      let(:value) { "0" }

      it "updates the form send_daily_submission_batch flag to false" do
        expect { input.submit }.to change { form.reload.send_daily_submission_batch }.to(false)
      end
    end
  end

  describe "#assign_form_values" do
    subject(:input) { described_class.new(form:) }

    let(:form) { create(:form, send_daily_submission_batch: true) }

    it "sets the send_daily_submission_batch value from the form" do
      input.assign_form_values

      expect(input.send_daily_submission_batch).to be(true)
    end
  end
end
