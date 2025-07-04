require "rails_helper"

class TestInput < BaseInput
  attr_accessor :name, :email

  validates :name, presence: true
  validates :email, format: { with: /.*@.*/, message: "must be a valid email address" }
end

RSpec.describe BaseInput do
  describe "validation error logging" do
    let(:analytics_service) { class_double(AnalyticsService).as_stubbed_const }

    before do
      allow(CurrentLoggingAttributes).to receive(:validation_errors=)
      allow(analytics_service).to receive(:track_validation_errors)
    end

    context "when there are no validation errors" do
      let(:input) { TestInput.new(name: "John Doe", email: "john@example.com") }

      it "is valid" do
        expect(input).to be_valid
      end

      it "does not log validation errors" do
        input.valid?
        expect(CurrentLoggingAttributes).not_to have_received(:validation_errors=)
      end

      it "does not track validation errors" do
        input.valid?
        expect(analytics_service).not_to have_received(:track_validation_errors)
      end
    end

    context "when there are validation errors" do
      let(:input) { TestInput.new }

      it "is invalid" do
        expect(input).to be_invalid
      end

      it "sets validation errors on CurrentLoggingAttributes" do
        input.valid?

        expect(CurrentLoggingAttributes).to have_received(:validation_errors=)
          .with(array_including("name: blank", "email: invalid"))
      end

      it "tracks each validation error through AnalyticsService" do
        input.valid?

        expect(analytics_service).to have_received(:track_validation_errors)
          .with(input_object_name: "TestInput", field: :name, error_type: :blank)

        expect(analytics_service).to have_received(:track_validation_errors)
          .with(input_object_name: "TestInput", field: :email, error_type: :invalid)
      end
    end
  end
end
