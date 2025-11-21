require "rails_helper"

RSpec.describe "config/initializers/sentry" do
  let(:test_dsn) { "https://fake@test-dsn/1".freeze }

  before do
    allow(Settings.sentry).to receive(:dsn).and_return(test_dsn)

    load "config/initializers/sentry.rb"

    setup_sentry_test
  end

  after do
    teardown_sentry_test
  end

  context "when an exception is raised containing personally identifying information" do
    let(:form) { create :form, submission_email: "submission-email@test.example" }

    before do
      raise "Something went wrong: #{form.inspect}"
    rescue RuntimeError => e
      Sentry.set_context(:user, { email: "user@example.org", id: "some-user-id" })
      Sentry.capture_exception(e)
    end

    it "captures the exception" do
      expect(last_sentry_event).to be_present
    end

    it "scrubs email addresses from everywhere in the event" do
      expect(last_sentry_event.to_h.to_s).not_to include "submission-email@test.example"
      expect(last_sentry_event.to_h.to_s).not_to include "user@example.org"
    end

    it "replaces the email address in the exception with a mask" do
      expect(last_sentry_event.to_h[:exception][:values].first[:value]).to include "[Filtered (client-side)]"
    end

    it "keeps the rest of the exception message" do
      expect(last_sentry_event.to_h[:exception][:values].first[:value]).to include "Something went wrong"
    end

    it "replaces the email address in the context with a mask" do
      expect(last_sentry_event.contexts[:user][:email]).to eq "[Filtered (client-side)]"
    end

    it "keeps the rest of the context" do
      expect(last_sentry_event.contexts[:user][:id]).to eq "some-user-id"
    end
  end

  context "when an breadcrumb is sent containing personally identifying information" do
    before do
      Sentry.add_breadcrumb(
        Sentry::Breadcrumb.new(
          category: "spec.integration.sentry_spec",
          data: {
            action: "test_breadcrumb",
            params: {
              forms_submission_form: {
                temporary_submission: "new-submission-email@test.example",
                notify_response_id: "some-random-number-0000",
              },
            },
          },
        ),
      )

      Sentry.capture_message("breadcrumbs test")
    end

    it "scrubs email addresses from everywhere in the event" do
      expect(last_sentry_event.to_h.to_s).not_to include "new-submission-email@test.example"
    end

    it "replaces the email address in the breadcrumbs with a comment" do
      expect(last_sentry_event.to_h[:breadcrumbs][:values].last[:data]["params"]["forms_submission_form"]["temporary_submission"]).to eq "[Filtered (client-side)]"
    end
  end
end
