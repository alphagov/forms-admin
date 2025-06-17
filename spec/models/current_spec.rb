require "rails_helper"

RSpec.describe Current do
  # Reset Current after each test to avoid state leaking between tests
  after do
    described_class.reset
  end

  describe ".initialize_analytics_events" do
    it "initializes analytics_events as an empty array if nil" do
      expect(described_class.analytics_events).to be_nil
      described_class.initialize_analytics_events
      expect(described_class.analytics_events).to eq([])
    end

    it "does not overwrite existing analytics_events array" do
      described_class.analytics_events = ["existing event"]
      described_class.initialize_analytics_events
      expect(described_class.analytics_events).to eq(["existing event"])
    end
  end

  describe ".add_analytics_event" do
    it "adds an event with name and properties to analytics_events" do
      described_class.add_analytics_event("page_view", { url: "/home" })

      expect(described_class.analytics_events).to eq([
        { name: "page_view", properties: { url: "/home" } },
      ])
    end

    it "allows adding multiple events" do
      described_class.add_analytics_event("login", { user_id: 123 })
      described_class.add_analytics_event("page_view", { url: "/dashboard" })

      expect(described_class.analytics_events).to eq([
        { name: "login", properties: { user_id: 123 } },
        { name: "page_view", properties: { url: "/dashboard" } },
      ])
    end

    it "initializes analytics_events if nil" do
      expect(described_class.analytics_events).to be_nil
      described_class.add_analytics_event("test")
      expect(described_class.analytics_events).to be_an(Array)
      expect(described_class.analytics_events.length).to eq(1)
    end

    it "accepts an event with no properties" do
      described_class.add_analytics_event("simple_event")
      expect(described_class.analytics_events).to eq([
        { name: "simple_event", properties: {} },
      ])
    end
  end

  describe ".clear_analytics_events" do
    it "clears all analytics events" do
      described_class.add_analytics_event("event1")
      described_class.add_analytics_event("event2")

      expect(described_class.analytics_events.length).to eq(2)

      described_class.clear_analytics_events
      expect(described_class.analytics_events).to eq([])
    end

    it "works when analytics_events is nil" do
      expect(described_class.analytics_events).to be_nil
      described_class.clear_analytics_events
      expect(described_class.analytics_events).to eq([])
    end
  end

  describe "ActiveSupport::CurrentAttributes behavior" do
    it "isolates attributes between threads" do
      # This test demonstrates the core behavior of CurrentAttributes
      described_class.add_analytics_event("main_thread")

      thread = Thread.new do
        described_class.add_analytics_event("background_thread")
        described_class.analytics_events
      end

      thread_events = thread.value

      # The background thread should have its own isolated events
      expect(thread_events).to eq([{ name: "background_thread", properties: {} }])

      # The main thread should still have only its events
      expect(described_class.analytics_events).to eq([{ name: "main_thread", properties: {} }])
    end
  end
end
