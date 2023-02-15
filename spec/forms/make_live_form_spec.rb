require "rails_helper"

RSpec.describe Forms::MakeLiveForm, type: :model do
  let(:error_message) { I18n.t("activemodel.errors.models.forms/make_live_form.attributes.confirm_make_live.blank") }

  describe "Make Live Form" do
    it "is invalid if blank" do
      make_live_form = described_class.new(confirm_make_live: "")
      make_live_form.validate(:confirm_make_live)

      expect(make_live_form.errors.full_messages_for(:confirm_make_live)).to include(
        "Confirm make live #{error_message}",
      )
    end
  end

  describe "#submit" do
    let(:make_live_form) { described_class.new(form: build(:form, :with_pages, :with_support, what_happens_next_text: "We usually respond to applications within 10 working days.")) }

    context "when form is invalid" do
      it "returns false" do
        expect(make_live_form.submit).to eq false
      end

      it "sets error messages" do
        make_live_form.submit
        expect(make_live_form.errors.full_messages_for(:confirm_make_live)).to include(
          "Confirm make live #{error_message}",
        )
      end
    end

    context "when admin user decides not to make form live" do
      before do
        make_live_form.confirm_make_live = "not_made_live"
      end

      it "returns true" do
        expect(make_live_form.submit).to eq true
      end

      it "sets no error messages" do
        make_live_form.submit
        expect(make_live_form.errors).to be_empty
      end
    end

    context "when form is being made live" do
      around do |example|
        Timecop.freeze(Time.zone.local(2021, 1, 1, 4, 30, 0)) do
          example.run
        end
      end

      before do
        allow(make_live_form.form).to receive(:make_live!).and_return(:make_live_called)
        make_live_form.confirm_make_live = "made_live"
      end

      it "makes form live" do
        expect(make_live_form.submit).to eq :make_live_called
      end

      it "sets no error messages" do
        make_live_form.submit
        expect(make_live_form.errors).to be_empty
      end
    end

    context "when form is being made live but not all the required sections have been completed" do
      let(:make_live_form) { build :make_live_form }

      before do
        make_live_form.confirm_make_live = "made_live"
      end

      it "is invalid if submission_email is blank" do
        error_message = I18n.t("activemodel.errors.models.forms/make_live_form.attributes.confirm_make_live.missing_submission_email")
        make_live_form.form.submission_email = nil
        expect(make_live_form).not_to be_valid

        expect(make_live_form.errors.full_messages_for(:confirm_make_live)).to include("Confirm make live #{error_message}")
      end

      it "is invalid is no privacy_policy" do
        error_message = I18n.t("activemodel.errors.models.forms/make_live_form.attributes.confirm_make_live.missing_privacy_policy_url")
        make_live_form.form.privacy_policy_url = nil
        expect(make_live_form).not_to be_valid

        expect(make_live_form.errors.full_messages_for(:confirm_make_live)).to include("Confirm make live #{error_message}")
      end

      it "is invalid if no questions have been added" do
        error_message = I18n.t("activemodel.errors.models.forms/make_live_form.attributes.confirm_make_live.missing_pages")
        make_live_form.form.pages = []
        expect(make_live_form).not_to be_valid

        expect(make_live_form.errors.full_messages_for(:confirm_make_live)).to include("Confirm make live #{error_message}")
      end
    end
  end
end
