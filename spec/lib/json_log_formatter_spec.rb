require "rails_helper"
require_relative "../../app/lib/json_log_formatter"

RSpec.describe JsonLogFormatter do
  it "merges the JSON if message is JSON" do
    input_json_message = { one: 1, two: 2 }.to_json
    expected_output = "{\"level\":\"INFO\",\"time\":\"10:00\",\"one\":1,\"two\":2}\n"

    expect(described_class.new.call("INFO", "10:00", "testing", input_json_message)).to eq(expected_output)
  end

  it "adds the message as message field if it is a string" do
    input_message = "just a simple string"
    expected_output = "{\"level\":\"INFO\",\"time\":\"10:00\",\"message\":\"just a simple string\"}\n"

    expect(described_class.new.call("INFO", "10:00", "testing", input_message)).to eq(expected_output)
  end

  it "prints an empty message if message is empty" do
    input_message = ""
    expected_output = "{\"level\":\"INFO\",\"time\":\"10:00\",\"message\":\"\"}\n"

    expect(described_class.new.call("INFO", "10:00", "testing", input_message)).to eq(expected_output)
  end

  it "prints a null message if message is nil" do
    input_message = nil
    expected_output = "{\"level\":\"INFO\",\"time\":\"10:00\",\"message\":null}\n"

    expect(described_class.new.call("INFO", "10:00", "testing", input_message)).to eq(expected_output)
  end
end
