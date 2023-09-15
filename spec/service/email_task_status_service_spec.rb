require "rails_helper"

describe EmailTaskStatusService do
  let(:email_task_status_service) do
    described_class.new(form:)
  end

  let(:current_user) { build(:user, role: :editor) }

  describe "#ready_for_live?" do
    context "when mandatory tasks have not been completed" do
      let(:form) { build(:form, :new_form) }

      it "returns false" do
        expect(email_task_status_service.ready_for_live?).to eq false
      end
    end

    context "when mandatory tasks have been completed" do
      let(:form) { build(:form, :ready_for_live) }

      it "returns true" do
        expect(email_task_status_service.ready_for_live?).to eq true
      end
    end
  end

  describe "#incomplete_email_tasks" do
    context "when mandatory tasks are complete" do
      let(:form) { build :form, :live }

      it "returns no incomplete tasks" do
        expect(email_task_status_service.incomplete_email_tasks).to be_empty
      end
    end

    context "when a form is incomplete and should still be in draft state" do
      let(:form) { build :form, :new_form }

      it "returns a set of keys related to missing fields" do
        expect(email_task_status_service.incomplete_email_tasks).to match_array(%i[missing_submission_email])
      end
    end
  end

  describe "#email_task_statuses" do
    let(:form) { build :form, :live }

    it "returns a hash with each of the email task statuses" do
      expected_hash = {
        submission_email_status: :completed,
        confirm_submission_email_status: :completed,
      }
      expect(email_task_status_service.email_task_statuses).to eq expected_hash
    end
  end
end
