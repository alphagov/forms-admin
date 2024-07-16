require "json"

class ApplicationLogger < ActiveSupport::Logger
  def debug(*msg, &block)
    value = as_hash(msg[0], msg[1], &block)
    super(value, &nil)
  end

  def info(*msg, &block)
    value = as_hash(msg[0], msg[1], &block)
    super(value, &nil)
  end

  def warn(*msg, &block)
    value = as_hash(msg[0], msg[1], &block)
    super(value, &nil)
  end

  def error(*msg, &block)
    value = as_hash(msg[0], msg[1], &block)
    super(value, &nil)
  end

  def fatal(*msg, &block)
    value = as_hash(msg[0], msg[1], &block)
    super(value, &nil)
  end

private

  def as_hash(msg, attribs = {})
    msg = yield if block_given?

    begin
      message_to_hash(msg).merge(attribs || {}).merge(CurrentLoggingAttributes.attributes).compact
    rescue NameError
      # if logs aren't attached to a request, CurrentLoggingAttributes will be uninitialized
      message_to_hash(msg).merge(attribs || {})
    end
  end

  def message_to_hash(message)
    return { message: } if message.is_a? String
    return message if message.is_a? Hash

    raise ArgumentError, "message must be a string or hash"
  end
end
