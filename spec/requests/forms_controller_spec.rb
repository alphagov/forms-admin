require "rails_helper"

RSpec.describe FormsController, type: :request do
  let(:form) { create(:form, name: "Form name", creator_id: 123) }
  let(:user) { standard_user }
  let(:group) { create(:group, organisation: user.organisation, status: :active) }

  before do
    Membership.create!(group_id: group.id, user:, added_by: user, role: :group_admin)
    GroupForm.create!(form:, group_id: group.id)
    create(:organisation_admin_user, organisation: user.organisation)
    login_as user
  end

  describe "#alert_org_admins_if_draft_created", :feature_org_admin_alerts_enabled do
    before do
      # Adding a new question loads in the form again from the database during creation. Post to this route to test that
      # this triggers an alert email for the status change even though the Form model loaded in by the controller isn't
      # directly updated.
      create :draft_question_for_new_page, user:, form_id: form.id
      post(create_question_path(form.id), params: {
        submit_type: "save",
        pages_question_input: {
          question_text: "Some question",
          hint_text: "",
          is_optional: false,
          is_repeatable: false,
        },
      })
    end

    context "when submitting to a route creates a draft of an existing form" do
      let(:form) { create(:form, :live) }

      it "sends an email to the organisation admins" do
        expect(response).to have_http_status(:redirect)
        expect(form.reload).to be_live_with_draft
        expect(ActionMailer::Base.deliveries.count).to eq(1)

        template_id = Settings.govuk_notify.org_admin_alerts.new_live_form_draft_created_template_id
        expect(ActionMailer::Base.deliveries.last.govuk_notify_template).to eq(template_id)
      end
    end

    context "when submitting to a route does not create a draft" do
      let(:form) { create(:form, :live_with_draft) }

      it "does not send an email to the organisation admins" do
        expect(response).to have_http_status(:redirect)
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end
  end
end
