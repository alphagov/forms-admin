class AnalyticsService
  class << self
    def track_validation_errors(input_object_name:, field:, error_type:)
      add_event("validation_error", {
        event_name: "validation_error",
        form_name: input_object_name,
        error_field: field,
        error_type: error_type,
      })
    end

    def add_events_from_flash(flash)
      flash.each do |event|
        add_event(
          event["name"] || event[:name],
          event["properties"] || event[:properties],
        )
      end
    end

    delegate :analytics_events, to: :Current

  private

    def add_event(name, properties)
      Current.add_analytics_event(name, properties)
    end
  end
end
