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

    context "when form is being made live but not all the required sections have been completed" do
      let(:make_live_form) { build :make_live_form }

      before do
        make_live_form.form.ready_for_live = false

        make_live_form.confirm_make_live = "made_live"
      end

      it "is invalid if submission_email is missing" do
        make_live_form.form.submission_email = nil

        expect(make_live_form).not_to be_valid
        expect(make_live_form.errors.full_messages_for(:confirm_make_live)).to include("Confirm make live #{I18n.t('activemodel.errors.models.forms/make_live_form.attributes.confirm_make_live.missing_submission_email')}")
      end
    end
  end
end
