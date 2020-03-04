redis_options = { url: "redis://#{ENV["REDIS_HOST"]}:#{ENV["REDIS_PORT"]}/1" }

if Rails.env.test?
  redis_options[:driver] = Redis::Connection::Memory if defined?(Redis::Connection::Memory)
end

Sidekiq.configure_server do |config|
  config.redis = redis_options
end
Sidekiq::Extensions.enable_delay!
