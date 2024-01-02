require "rails_helper"

RSpec.describe "config/initializers/sentry" do
  attr_accessor :captured_event, :filtered_event

  test_dsn = "https://fake@test-dsn/1".freeze

  before :context do # rubocop:disable RSpec/BeforeAfterAll
    if Settings.sentry.dsn.nil?
      Settings.sentry.dsn = test_dsn

      load "config/initializers/sentry.rb"
    end
  end

  after :context do # rubocop:disable RSpec/BeforeAfterAll
    if Settings.sentry.dsn == test_dsn
      Sentry.close

      Settings.sentry.dsn = nil
    end
  end

  before do
    allow(Sentry.configuration).to receive(:before_send).and_wrap_original do |original_method|
      original_method = original_method.call
      lambda do |event, hint|
        @captured_event = event
        @filtered_event = original_method.nil? ? event : original_method.call(event, hint)
      end
    end
  end

  context "when an exception is raised containing personally identifying information" do
    let(:form) { build :form, id: 1, submission_email: "submission-email@test.example" }

    before do
      form.not_a_method
    rescue NameError => e
      Sentry.capture_exception(e)
    end

    it "scrubs email addresses from everywhere in the event" do
      expect(filtered_event.to_hash.to_s).not_to include "submission-email@test.example"
    end

    it "keeps the rest of the exception message" do
      expect(filtered_event.to_hash[:exception][:values].first[:value]).to eq "undefined method `not_a_method' for an instance of Form (NoMethodError)"
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
      expect(filtered_event.to_hash.to_s).not_to include "new-submission-email@test.example"
    end

    it "replaces the email address in the breadcrumbs with a comment" do
      expect(filtered_event.to_hash[:breadcrumbs][:values].last[:data]["params"]["forms_submission_form"]["temporary_submission"]).to eq "[Filtered (client-side)]"
    end
  end
end
