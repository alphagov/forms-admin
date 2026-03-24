require "rails_helper"

RSpec.describe Forms::BatchSubmissionsInput, type: :model do
  describe "#submit" do
    subject(:input) do
      described_class.new(
        form:,
        batch_frequencies:,
      )
    end

    context "when batch submissions are initially disabled" do
      let(:form) { create(:form, send_daily_submission_batch: false, send_weekly_submission_batch: false) }

      [
        [%w[daily], true, false],
        [%w[weekly], false, true],
        [%w[daily weekly], true, true],
        [[], false, false],
      ].each do |batch_frequencies, expected_daily, expected_weekly|
        context "when batch_frequencies is #{batch_frequencies.inspect}" do
          let(:batch_frequencies) { batch_frequencies }

          before do
            input.submit
          end

          it "updates the form send_daily_submission_batch flag to #{expected_daily}" do
            expect(form.reload.send_daily_submission_batch).to eq(expected_daily)
          end

          it "updates the form send_weekly_submission_batch flag to #{expected_weekly}" do
            expect(form.reload.send_weekly_submission_batch).to eq(expected_weekly)
          end
        end
      end
    end

    context "when batch submissions are initially enabled" do
      let(:form) { create(:form, send_daily_submission_batch: true, send_weekly_submission_batch: true) }

      [
        [%w[daily], true, false],
        [%w[weekly], false, true],
        [%w[daily weekly], true, true],
        [[], false, false],
      ].each do |batch_frequencies, expected_daily, expected_weekly|
        context "when batch_frequencies is #{batch_frequencies.inspect}" do
          let(:batch_frequencies) { batch_frequencies }

          before do
            input.submit
          end

          it "updates the form send_daily_submission_batch flag to #{expected_daily}" do
            expect(form.reload.send_daily_submission_batch).to eq(expected_daily)
          end

          it "updates the form send_weekly_submission_batch flag to #{expected_weekly}" do
            expect(form.reload.send_weekly_submission_batch).to eq(expected_weekly)
          end
        end
      end
    end
  end

  describe "#assign_form_values" do
    subject(:input) { described_class.new(form:) }

    [
      [true, false, %w[daily]],
      [false, true, %w[weekly]],
      [true, true, %w[daily weekly]],
      [false, false, []],
    ].each do |send_daily_submission_batch, send_weekly_submission_batch, expected|
      context "when send_daily_submission_batch is #{send_daily_submission_batch} and send_weekly_submission_batch is #{send_weekly_submission_batch}" do
        let(:form) { create(:form, send_daily_submission_batch:, send_weekly_submission_batch:) }

        it "sets batch_frequencies to #{expected.inspect}" do
          input.assign_form_values

          expect(input.batch_frequencies).to match_array(expected)
        end
      end
    end
  end
end
