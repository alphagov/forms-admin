require "rails_helper"

RSpec.describe AnalyticsService do
  describe ".track_validation_errors" do
    it "adds a validation_error event with correct parameters" do
      input_object_name = "user_form"
      form_name = "Apply for a juggling licence"
      field = "email"
      error_type = "invalid_format"
      expected_event_name = "validation_error"
      expected_properties = {
        input_object_name: input_object_name,
        form_name:,
        event_name: "validation_error",
        error_field: field,
        error_type: error_type,
      }

      expect(described_class).to receive(:add_event).with(
        expected_event_name,
        expected_properties,
      )

      described_class.track_validation_errors(
        input_object_name: input_object_name,
        form_name:,
        field: field,
        error_type: error_type,
      )
    end
  end

  describe ".add_events_from_flash" do
    context "with string keys in flash" do
      it "adds each flash event to analytics events" do
        flash = [
          {
            "name" => "flash_event_1",
            "properties" => { "key1" => "value1" },
          },
          {
            "name" => "flash_event_2",
            "properties" => { "key2" => "value2" },
          },
        ]

        flash.each do |event|
          expect(described_class).to receive(:add_event).with(
            event["name"],
            event["properties"],
          )
        end

        described_class.add_events_from_flash(flash)
      end
    end

    context "with symbol keys in flash" do
      it "adds each flash event to analytics events" do
        flash = [
          {
            name: "flash_event_1",
            properties: { key1: "value1" },
          },
          {
            name: "flash_event_2",
            properties: { key2: "value2" },
          },
        ]

        flash.each do |event|
          expect(described_class).to receive(:add_event).with(
            event[:name],
            event[:properties],
          )
        end

        described_class.add_events_from_flash(flash)
      end
    end

    context "with mixed string and symbol keys" do
      it "handles mixed key types correctly" do
        flash = [
          {
            "name" => "flash_event_1",
            "properties" => { "key1" => "value1" },
          },
          {
            name: "flash_event_2",
            properties: { key2: "value2" },
          },
        ]

        expect(described_class).to receive(:add_event).with(
          "flash_event_1",
          { "key1" => "value1" },
        )
        expect(described_class).to receive(:add_event).with(
          "flash_event_2",
          { key2: "value2" },
        )

        described_class.add_events_from_flash(flash)
      end
    end

    context "with empty flash" do
      it "does not call add_analytics_event" do
        flash = []

        expect(described_class).not_to receive(:add_event)
        described_class.add_events_from_flash(flash)
      end
    end
  end

  describe ".analytics_events" do
    it "delegates to Current.analytics_events" do
      mock_events = [{ name: "test_event", properties: { key: "value" } }]
      allow(Current).to receive(:analytics_events).and_return(mock_events)

      expect(described_class.analytics_events).to eq(mock_events)
    end
  end

  describe ".add_event" do
    it "calls Current.add_analytics_event with the correct parameters" do
      event_name = "test_event"
      event_properties = { key: "value" }

      expect(Current).to receive(:add_analytics_event).with(event_name, event_properties)

      described_class.send(:add_event, event_name, event_properties)
    end
  end
end
