class EventLogger
  def self.log(object)
    Rails.logger.info(object.to_json)
  end
end
