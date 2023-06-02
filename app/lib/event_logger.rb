class EventLogger
  def self.log(tag, object)
    Rails.logger.tagged(tag).info(object.to_json)
  end
end
