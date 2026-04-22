require "rails_helper"

RSpec.describe ApplicationLogger, :capture_logging do
  subject(:logger) do
    described_class.new(log_output).tap do |logger|
      logger.formatter = JsonLogFormatter.new
    end
  end

  context "when CurrentLoggingAttributes has attributes set" do
    before do
      CurrentLoggingAttributes.request_id = "a-request-id"
      logger.info("A message")
    end

    it "includes the message as a field" do
      expect(log_line["message"]).to eq "A message"
    end

    it "includes attributes with values on the log line" do
      expect(log_line["request_id"]).to eq "a-request-id"
    end

    it "does not include attributes without values on the log line" do
      expect(log_line.keys).not_to include "user_id"
    end
  end

  context "when a hash is passed as an argument" do
    before do
      CurrentLoggingAttributes.request_id = "a-request-id"
      logger.info("A message", { foo: "bar" })
    end

    it "includes the message as a field" do
      expect(log_line["message"]).to eq "A message"
    end

    it "includes entries in the hash on the log line" do
      expect(log_line["foo"]).to eq "bar"
    end

    it "includes attributes set on CurrentLoggingAttributes on the log line" do
      expect(log_line["request_id"]).to eq "a-request-id"
    end
  end

  context "when logged message is a hash" do
    before do
      CurrentLoggingAttributes.request_id = "a-request-id"
      logger.info({ foo: "bar" })
    end

    it "does not include a message field" do
      expect(log_line.keys).not_to include "message"
    end

    it "includes entries in the hash on the log line" do
      expect(log_line["foo"]).to eq "bar"
    end

    it "includes attributes set on CurrentLoggingAttributes on the log line" do
      expect(log_line["request_id"]).to eq "a-request-id"
    end
  end

  context "when logged message is not a string or a hash" do
    before do
      error = RuntimeError.new("An error occurred")
      logger.info(error)
    end

    it "includes the message as a field" do
      expect(log_line).to include "message"
    end

    it "includes the message as a string" do
      expect(log_line["message"]).to be_a String
      expect(log_line["message"]).to eq "An error occurred"
    end
  end
end
