class Current < ActiveSupport::CurrentAttributes
  attribute :analytics_events

  def initialize_analytics_events
    self.analytics_events ||= []
  end

  def add_analytics_event(name, properties = {})
    initialize_analytics_events
    self.analytics_events << { name: name, properties: properties }
  end

  def clear_analytics_events
    self.analytics_events = []
  end
end
