require "rails_helper"

RSpec.describe OrgAdminAlertsService do
  subject(:service) { described_class.new(form:, current_user:) }

  let(:form) { create(:form, :ready_for_live, state: previous_state) }
  let(:organisation) { create(:organisation, :with_signed_mou) }
  let(:group) { create(:group, organisation:) }
  let(:current_user) { create(:organisation_admin_user, organisation:) }
  let!(:organisation_admins) { create_list(:organisation_admin_user, 2, organisation:) }

  before do
    GroupForm.create!(form: form, group:)
  end

  describe "#form_made_live" do
    before do
      form.make_live! unless form.live?
    end

    context "when the previous state is draft" do
      let(:previous_state) { :draft }

      context "when form was not copied from another form" do
        it "sends the new draft form made live email to the organisation admins" do
          expect(OrgAdminAlerts::MadeLiveMailer).to receive(:new_draft_form_made_live).with(
            form: form,
            user: current_user,
            to_email: organisation_admins.first.email,
          ).and_call_original

          expect(OrgAdminAlerts::MadeLiveMailer).to receive(:new_draft_form_made_live).with(
            form: form,
            user: current_user,
            to_email: organisation_admins.second.email,
          ).and_call_original

          service.form_made_live

          expect(ActionMailer::Base.deliveries.size).to eq(2)
        end

        it "does not send an email to the current user" do
          allow(OrgAdminAlerts::MadeLiveMailer).to receive(:new_draft_form_made_live).and_call_original
          service.form_made_live

          expect(OrgAdminAlerts::MadeLiveMailer).not_to have_received(:new_draft_form_made_live).with(
            form: form,
            user: current_user,
            to_email: current_user.email,
          )
        end
      end

      context "when form was copied from another form" do
        let(:copied_from_form) { create(:form, :ready_for_live) }
        let(:form) { create(:form, :ready_for_live, state: previous_state, copied_from_id: copied_from_form.id) }

        it "sends the copied form made live email to the organisation admins" do
          expect(OrgAdminAlerts::MadeLiveMailer).to receive(:copied_form_made_live).with(
            form: form,
            copied_from_form: copied_from_form,
            user: current_user,
            to_email: organisation_admins.first.email,
          ).and_call_original

          expect(OrgAdminAlerts::MadeLiveMailer).to receive(:copied_form_made_live).with(
            form: form,
            copied_from_form: copied_from_form,
            user: current_user,
            to_email: organisation_admins.second.email,
          ).and_call_original

          service.form_made_live

          expect(ActionMailer::Base.deliveries.size).to eq(2)
        end
      end
    end

    context "when the previous state is live with draft" do
      let(:previous_state) { :live_with_draft }

      it "sends the live form changes made live email to the organisation admins" do
        expect(OrgAdminAlerts::MadeLiveMailer).to receive(:live_form_changes_made_live).with(
          form: form,
          user: current_user,
          to_email: organisation_admins.first.email,
        ).and_call_original

        expect(OrgAdminAlerts::MadeLiveMailer).to receive(:live_form_changes_made_live).with(
          form: form,
          user: current_user,
          to_email: organisation_admins.second.email,
        ).and_call_original

        service.form_made_live

        expect(ActionMailer::Base.deliveries.size).to eq(2)
      end
    end

    context "when the previous state is archived" do
      let(:previous_state) { :archived }

      it "sends the archived form made live email to the organisation admins" do
        expect(OrgAdminAlerts::MadeLiveMailer).to receive(:archived_form_made_live).with(
          form: form,
          user: current_user,
          to_email: organisation_admins.first.email,
        ).and_call_original

        expect(OrgAdminAlerts::MadeLiveMailer).to receive(:archived_form_made_live).with(
          form: form,
          user: current_user,
          to_email: organisation_admins.second.email,
        ).and_call_original

        service.form_made_live

        expect(ActionMailer::Base.deliveries.size).to eq(2)
      end
    end

    context "when the previous state is archived with draft" do
      let(:previous_state) { :archived_with_draft }

      it "sends the archived form changes made live email to the organisation admins" do
        expect(OrgAdminAlerts::MadeLiveMailer).to receive(:archived_form_changes_made_live).with(
          form: form,
          user: current_user,
          to_email: organisation_admins.first.email,
        ).and_call_original

        expect(OrgAdminAlerts::MadeLiveMailer).to receive(:archived_form_changes_made_live).with(
          form: form,
          user: current_user,
          to_email: organisation_admins.second.email,
        ).and_call_original

        service.form_made_live

        expect(ActionMailer::Base.deliveries.size).to eq(2)
      end
    end

    context "when the previous state is unexpected" do
      let(:previous_state) { :live }

      it "raises an error and does not send any emails" do
        expect {
          service.form_made_live
        }.to raise_error(StandardError, "Unexpected previous state: live")

        expect(ActionMailer::Base.deliveries.size).to eq(0)
      end
    end
  end
end
