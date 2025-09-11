if Rails.env.production?
  redis_url = ENV.fetch("REDIS_URL", nil)
  if redis_url
    Rack::MiniProfiler.config.storage_options = { url: redis_url }
    Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
  end

  Rack::MiniProfiler.config.authorization_mode = :allow_authorized
end
