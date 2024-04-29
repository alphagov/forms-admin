require "rails_helper"

RSpec.describe Forms::MakeLiveForm, type: :model do
  let(:error_message) { I18n.t("activemodel.errors.models.forms/make_live_form.attributes.confirm.blank") }

  describe "Make Live Form" do
    it "is invalid if blank" do
      make_live_form = described_class.new(confirm: "")
      make_live_form.validate(:confirm)

      expect(make_live_form.errors.full_messages_for(:confirm)).to include(
        "Confirm #{error_message}",
      )
    end

    context "when form is being made live but not all the required sections have been completed" do
      let(:make_live_form) { build :make_live_form }

      before do
        make_live_form.form.ready_for_live = false

        make_live_form.confirm = "yes"
      end

      it "is invalid if submission_email is missing" do
        make_live_form.form.submission_email = nil

        expect(make_live_form).not_to be_valid
        expect(make_live_form.errors.full_messages_for(:confirm)).to include("Confirm #{I18n.t('activemodel.errors.models.forms/make_live_form.attributes.confirm.missing_submission_email')}")
      end
    end
  end

  describe "#user_wants_to_make_form_live" do
    [
      { valid: true, confirmed: true },
      { valid: true, confirmed: false },
      { valid: false, confirmed: true },
      { valid: false, confirmed: false },
    ].each do |scenario|
      context "when valid? returns #{scenario[:valid]} and confirmed? returns #{scenario[:confirmed]}" do
        let(:make_live_form) { described_class.new(confirm: "") }

        before do
          allow(make_live_form).to receive(:valid?).and_return(scenario[:valid])
          allow(make_live_form).to receive(:confirmed?).and_return(scenario[:confirmed])
        end

        it "returns #{scenario[:valid] && scenario[:confirmed]}" do
          expect(make_live_form.user_wants_to_make_form_live).to eq scenario[:valid] && scenario[:confirmed]
        end
      end
    end
  end

  describe "#make_form_live" do
    [
      { valid: true, make_live: true },
      { valid: true, make_live: false },
      { valid: false, make_live: true },
      { valid: false, make_live: false },
    ].each do |scenario|
      context "when valid? returns #{scenario[:valid]} and make_live? returns #{scenario[:make_live]}" do
        let(:make_live_form) { described_class.new(confirm: "") }
        let(:make_form_live_service) { OpenStruct.new(make_live: scenario[:make_live]) }

        before do
          allow(make_live_form).to receive(:valid?).and_return(scenario[:valid])
        end

        it "returns #{scenario[:valid] && scenario[:make_live]}" do
          expect(make_live_form.make_form_live(make_form_live_service)).to eq scenario[:valid] && scenario[:make_live]
        end
      end
    end
  end
end
