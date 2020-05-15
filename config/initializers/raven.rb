Raven.configure do |config|
  config.dsn = "https://2c260e29a9ac47f4a0dfea524fac2fd6@o42691.ingest.sentry.io/5241851"
  config.sanitize_fields = Rails.configuration.filter_parameters.map(&:to_s)
  config.current_environment = Rails.env
  config.environments = %w(production)
  config.excluded_exceptions = Raven::Configuration::IGNORE_DEFAULT - %w(
    AbstractController::ActionNotFound
  ) + %w(
    ActionController::UnknownHttpMethod
    SignalException
    Sentry::Sidekiq::SilentRetryError
  )
  config.silence_ready = true
end
