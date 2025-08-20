require "rails_helper"

RSpec.describe Forms::SubmissionEmailController, type: :request do
  include ActionView::Helpers::TextHelper

  let(:organisation) { build :organisation, id: 1, slug: "test-org" }
  let(:user) { standard_user }
  let(:user_outside_group) { build :user, id: 2, organisation: }

  let(:form) { create :form, creator_id: 1 }
  let(:made_live_form) { build(:made_live_form, id: form.id) }

  let(:submission_email_mailer_spy) do
    submission_email_mailer = instance_spy(SubmissionEmailMailer)
    allow(SubmissionEmailMailer).to receive(:new).and_return(submission_email_mailer)
    submission_email_mailer
  end

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    allow(FormRepository).to receive_messages(find: form, save!: form, find_live: made_live_form)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)

    login_as user
  end

  describe "#new" do
    before do
      get submission_email_input_path(form.id)
    end

    it "returns HTTP code 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct page" do
      expect(response).to render_template(:new)
    end

    context "when current user does not belong to the group" do
      let(:user) { user_outside_group }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#create" do
    let(:temporary_submission_email) { user.email }

    before do
      allow(submission_email_mailer_spy).to receive(:send_confirmation_code)

      post(
        submission_email_path(form.id),
        params: {
          forms_submission_email_input: {
            temporary_submission_email:,
            notify_response_id: Faker::Internet.uuid,
          },
        },
      )
    end

    it "redirects to the email code sent page" do
      expect(response).to redirect_to(submission_email_code_sent_path(form.id))
    end

    context "when user submits an invalid email address" do
      let(:temporary_submission_email) { "a@gmail.com" }

      it "does not accept the submission email address" do
        expect(response.body).to include I18n.t("error_summary.heading")
        expect(response.body).to include I18n.t("errors.messages.non_government_email")
        expect(response).to have_http_status :unprocessable_content
      end
    end

    context "when current user does not belong to group" do
      let(:user) { user_outside_group }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when current user has a government email address not ending with .gov.uk" do
      let(:user) { standard_user.tap { |user| user.email = "user@alb.example" } }

      it "redirects to the email code sent page" do
        expect(response).to redirect_to(submission_email_code_sent_path(form.id))
      end
    end
  end

  describe "#submission_email_code_sent" do
    before do
      get submission_email_code_sent_path(form.id)
    end

    it "returns HTTP code 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct page" do
      expect(response).to render_template(:submission_email_code_sent)
    end

    context "when current user does not belong to the group" do
      let(:user) { user_outside_group }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#submission_email_code" do
    before do
      get submission_email_code_path(form.id)
    end

    it "returns HTTP code 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct page" do
      expect(response).to render_template(:submission_email_code)
    end

    context "when current user does not belong to the group" do
      let(:user) { user_outside_group }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#confirm_submission_email_code" do
    let(:confirmation_code) { "123456" }
    let(:submitted_code) { confirmation_code }

    before do
      allow(FormSubmissionEmail).to receive(:find_by_form_id).and_return(build(
                                                                           :form_submission_email,
                                                                           form_id: 1,
                                                                           temporary_submission_email: user.email,
                                                                           confirmation_code:,
                                                                         ))

      post(
        confirm_submission_email_code_path(form.id),
        params: {
          forms_submission_email_input: {
            email_code: submitted_code,
          },
        },
      )
    end

    it "redirects to the confirmation page" do
      expect(response).to redirect_to(submission_email_confirmed_path(form.id))
    end

    context "when user submits the wrong confirmation code" do
      let(:submitted_code) { "123455" }

      it "responds with an error" do
        expect(response.body).to include I18n.t("error_summary.heading")
        expect(response).to have_http_status :unprocessable_content
      end
    end

    context "when current user does not belong to the group" do
      let(:user) { user_outside_group }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#submission_email_confirmed" do
    context "when the form is not live" do
      before do
        get submission_email_confirmed_path(form.id)
      end

      it "returns HTTP code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the correct page" do
        expect(response).to render_template(:submission_email_confirmed)
      end

      context "when current user does not belong to the group" do
        let(:user) { user_outside_group }

        it "is forbidden" do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context "when draft version submission email is different from live version" do
      let(:form) { create :form, :live, creator_id: 1 }
      let(:previous_live_version) { build :made_live_form, creator_id: 1, id: form.id, submission_email: Faker::Internet.email(domain: "test.example.gov.uk") }

      before do
        form.submission_email = Faker::Internet.email(domain: "different.gov.uk")

        allow(FormRepository).to receive_messages(find: form, find_live: previous_live_version)

        get submission_email_confirmed_path(form.id)
      end

      it "displays the default text and tells users we will email form processing team" do
        expect(response.body).to include(simple_format(I18n.t("email_code_success.live_submission_email_changed_body_html", new_submission_email: form.submission_email)))
      end
    end
  end
end
