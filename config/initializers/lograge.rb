Rails.application.configure do
  config.lograge.enabled = true if Rails.env.production?

  config.lograge.custom_options = lambda do |event|
    {}.tap do |h|
      h[:host] = event.payload[:host]
      h[:user_id] = event.payload[:user_id]
      h[:user_email] = event.payload[:user_email]
      h[:user_organisation_slug] = event.payload[:user_organisation_slug]
      h[:request_id] = event.payload[:request_id]
      h[:user_id] = event.payload[:user_id]
      h[:form_id] = event.payload[:form_id] if event.payload[:form_id]
    end
  end

  config.lograge.formatter = Lograge::Formatters::Json.new
end
