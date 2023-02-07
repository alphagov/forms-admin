# frozen_string_literal: true

require "rails_helper"

describe "Settings" do
  settings = YAML.load_file(Rails.root.join("config/settings.yml")).with_indifferent_access
  expected_value_test = "expected_value_test"

  shared_examples expected_value_test do |key, source, expected_value|
    describe ".#{key}" do
      subject do
        source[key]
      end

      it "#{key} has a default value" do
        expect(subject).to eq(expected_value)
      end
    end
  end

  describe ".features" do
    features = settings[:features]

    include_examples expected_value_test, :draft_live_versioning, features, false
    include_examples expected_value_test, :live_view, features, false
    include_examples expected_value_test, :reorder_pages, features, true
    include_examples expected_value_test, :autocomplete_answer_types, features, false
  end

  describe "govuk_notify" do
    govuk_notify = settings[:govuk_notify]

    include_examples expected_value_test, :api_key, govuk_notify, "changeme"

    include_examples expected_value_test, :submission_email_confirmation_code_email_template_id, govuk_notify, "ce2638ab-754c-416d-8df6-c0ccb5e1a688"
  end

  describe "sentry" do
    sentry = settings[:sentry]

    include_examples expected_value_test, :dsn, sentry, nil

    include_examples expected_value_test, :environment, sentry, "local"
  end
end
