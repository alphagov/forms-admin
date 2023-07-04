require "rails_helper"

RSpec.describe Forms::SubmissionEmailController, type: :request do
  let(:organisation) { build :organisation, slug: "test-org" }
  let(:user) { build :user, role: :editor, id: 1, organisation: }
  let(:form) { build :form, id: 1, creator_id: 1, org: "test-org" }

  let(:submission_email_mailer_spy) do
    submission_email_mailer = instance_spy(SubmissionEmailMailer)
    allow(SubmissionEmailMailer).to receive(:new).and_return(submission_email_mailer)
    submission_email_mailer
  end

  let(:req_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  let(:post_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Content-Type" => "application/json",
    }
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms", req_headers, [form].to_json, 200
      mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
      mock.put "/api/v1/forms/1", post_headers, { success: true }.to_json, 200
    end

    login_as user
  end

  describe "#new" do
    before do
      get submission_email_form_path(form.id)
    end

    it "returns HTTP code 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct page" do
      expect(response).to render_template(:new)
    end

    context "when current user does not own form" do
      let(:form) { build :form, id: 1, creator_id: 2, org: "other-org" }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when current user has a trial account" do
      let(:user) { build :user, :with_trial_role, id: 1 }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#create" do
    before do
      allow(submission_email_mailer_spy).to receive(:confirmation_code_email)

      post(
        submission_email_path(form.id),
        params: {
          forms_submission_email_form: {
            temporary_submission_email: user.email,
            notify_response_id: Faker::Internet.uuid,
          },
        },
      )
    end

    it "redirects to the email code sent page" do
      expect(response).to redirect_to(submission_email_code_sent_path(form.id))
    end

    context "when current user does not own form" do
      let(:form) { build :form, id: 1, creator_id: 2, org: "other-org" }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when current user has a trial account" do
      let(:user) { build :user, :with_trial_role, id: 1 }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
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

    context "when current user does not own form" do
      let(:form) { build :form, id: 1, creator_id: 2, org: "other-org" }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when current user has a trial account" do
      let(:user) { build :user, :with_trial_role, id: 1 }

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

    context "when current user does not own form" do
      let(:form) { build :form, id: 1, creator_id: 2, org: "other-org" }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when current user has a trial account" do
      let(:user) { build :user, :with_trial_role, id: 1 }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#confirm_submission_email_code" do
    before do
      allow(FormSubmissionEmail).to receive(:find_by_form_id).and_return(build(
                                                                           :form_submission_email,
                                                                           form_id: 1,
                                                                           temporary_submission_email: user.email,
                                                                           confirmation_code: "123456",
                                                                         ))

      post(
        confirm_submission_email_code_path(form.id),
        params: {
          forms_submission_email_form: {
            email_code: "123456",
          },
        },
      )
    end

    it "redirects to the confirmation page" do
      expect(response).to redirect_to(submission_email_confirmed_path(form.id))
    end

    context "when current user does not own form" do
      let(:form) { build :form, id: 1, creator_id: 2, org: "other-org" }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when current user has a trial account" do
      let(:user) { build :user, :with_trial_role, id: 1 }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#submission_email_confirmed" do
    before do
      get submission_email_confirmed_path(form.id)
    end

    it "returns HTTP code 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct page" do
      expect(response).to render_template(:submission_email_confirmed)
    end

    context "when current user does not own form" do
      let(:form) { build :form, id: 1, creator_id: 2, org: "other-org" }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when current user has a trial account" do
      let(:user) { build :user, :with_trial_role, id: 1 }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
