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
    let(:make_live_form) { described_class.new(form: OpenStruct.new(live_at: nil)) }

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
        form.confirm_make_live = "made_live"
      end

      it "sets live_at to current date/time" do
        make_form = form
        form.submit
        expect(make_form.form.live_at).to eq " 2021-01-01 04:30:00.000000000 +0000"
      end

      it "sets no error messages" do
        make_live_form = form
        make_live_form.submit
        expect(make_live_form.errors).to be_empty
      end
    end

    context "when form is being made live but not all the required sections have been completed" do
      before(:each) do
        make_live_form.confirm_make_live = "made_live"
        make_live_form.form = build(:form)
      end

      it "is invalid if submission_email is blank" do
        error_message = "You cannot make your form live because it does not have an email address to send completed forms to. Answer ‘No’ and add an email address."
        make_live_form.form.submission_email = nil
        expect(make_live_form).not_to be_valid

        expect(make_live_form.errors.full_messages_for(:confirm_make_live)).to include("Confirm make live #{error_message}")
      end

      it "is invalid is no privacy_policy" do
        error_message = "You cannot make your form live because it does not have a link to privacy information. Answer ‘No’ and add a link."
        make_live_form.form.privacy_policy_url = nil
        expect(make_live_form).not_to be_valid

        expect(make_live_form.errors.full_messages_for(:confirm_make_live)).to include("Confirm make live #{error_message}")
      end

      it "is invalid if no questions have been added" do
        error_message = "You cannot make your form live because it does not have any questions. Answer ‘No’ and add one or more questions."
        make_live_form.form.pages = []
        expect(make_live_form).not_to be_valid

        expect(make_live_form.errors.full_messages_for(:confirm_make_live)).to include("Confirm make live #{error_message}")
      end
    end
  end
end
