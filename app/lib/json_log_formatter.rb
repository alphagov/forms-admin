class JsonLogFormatter < ActiveSupport::Logger::Formatter
  def call(severity, timestamp, _progname, message)
    log_event = {
      level: severity,
      time: timestamp,
    }

    if message.is_a? Hash
      log_event.merge!(message)
    else
      log_event[:message] = message
    end

    "#{log_event.to_json}\n"
  end
end
