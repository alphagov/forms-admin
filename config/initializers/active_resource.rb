# Lets log all requests to the API in development only for now
if Rails.env.development?
  ActiveSupport::Notifications.subscribe("request.active_resource") do |_name, _time, _stamp, _id, payload|
    method = payload[:method]
    request = payload[:request_uri]
    Rails.logger.info "FORMS_API: #{method} #{request}"
  end
end
