require "rails_helper"

RSpec.describe Forms::MakeLiveInput, type: :model do
  let(:error_message) { I18n.t("activemodel.errors.models.forms/make_live_input.attributes.confirm.blank") }

  describe "validations" do
    it "is invalid if blank" do
      make_live_input = described_class.new(confirm: "")
      make_live_input.validate(:confirm)

      expect(make_live_input.errors.full_messages_for(:confirm)).to include(
        "Confirm #{error_message}",
      )
    end

    context "when form is being made live but not all the required sections have been completed" do
      let(:make_live_input) { build :make_live_input }

      before do
        make_live_input.form.ready_for_live = false

        make_live_input.confirm = "yes"
      end

      it "is invalid if submission_email is missing" do
        make_live_input.form.submission_email = nil

        expect(make_live_input).not_to be_valid
        expect(make_live_input.errors.full_messages_for(:confirm)).to include("Confirm #{I18n.t('activemodel.errors.models.forms/make_live_input.attributes.confirm.missing_submission_email')}")
      end

      context "when the API returns incomplete tasks" do
        let(:incomplete_tasks) { %i[missing_pages missing_privacy_policy_url missing_contact_details missing_what_happens_next share_preview_not_completed] }

        before do
          make_live_input.form.incomplete_tasks = incomplete_tasks
        end

        it "shows a validation message for the incomplete task" do
          expect(make_live_input).not_to be_valid

          incomplete_tasks.each do |incomplete_task_name|
            expect(make_live_input.errors.full_messages_for(:confirm)).to include("Confirm #{I18n.t("activemodel.errors.models.forms/make_live_input.attributes.confirm.#{incomplete_task_name}")}")
          end
        end
      end
    end
  end
end
