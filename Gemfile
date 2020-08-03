source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '< 6.0.1'
gem 'pg', '~> 1.0.0'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

gem 'activerecord-import'
gem 'activerecord-import-sqlserver'
gem 'activerecord-sqlserver-adapter'
gem 'active_record_union'
gem 'attr_encrypted', '~> 3.1.0'
gem 'composite_primary_keys'
gem 'dry-initializer'
gem 'friendly_id', '~> 5.2.4' # Note: You MUST use 5.0.0 or greater for Rails 4.0+
gem 'graphql-client'
gem 'httparty'
gem 'knock'
gem 'redis'
gem 'slack-notifier'
gem 'sidekiq'
gem 'sentry-raven'
gem 'tiny_tds'
gem 'rails-i18n'
gem 'will_paginate', '>= 3.1.0'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
