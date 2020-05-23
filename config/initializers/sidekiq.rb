if ENV["REDIS_HOST"]
  redis_options = { url: "redis://#{ENV["REDIS_HOST"]}:#{ENV["REDIS_PORT"]}/1" }
else
  redis_options = { url: "redis://127.0.0.1:6379/1" }
end

if Rails.env.test?
  redis_options[:driver] = Redis::Connection::Memory if defined?(Redis::Connection::Memory)
end

Sidekiq.configure_server do |config|
  config.redis = redis_options
end

Sidekiq.configure_client do |config|
  config.redis = redis_options
end
Sidekiq::Extensions.enable_delay!
