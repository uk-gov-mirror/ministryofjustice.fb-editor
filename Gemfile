source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'activerecord-session_store'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'daemons'
gem 'delayed_job_active_record'

# Metadata presenter - if you need to be on development you can uncomment
# one of these lines:
# gem 'metadata_presenter',
#     github: 'ministryofjustice/fb-metadata-presenter',
#     branch: 'default-text'
# gem 'metadata_presenter', path: '../fb-metadata-presenter'

gem 'faraday'
gem 'faraday_middleware'
gem 'fb-jwt-auth', '0.6.0'
gem 'hashie'
gem 'metadata_presenter', '0.26.1'
gem 'omniauth-auth0', '~> 2.6.0'
gem 'omniauth-rails_csrf_protection', '~> 0.1.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 5.2'
gem 'rails', '~> 6.1.3'
gem 'sass-rails', '>= 6'
gem 'sentry-delayed_job', '~> 4.3.1'
gem 'sentry-rails', '~> 4.3.4'
gem 'sentry-ruby', '~> 4.3.1'
gem 'tzinfo-data'
gem 'webpacker', '~> 5.2'

group :development, :test do
  gem 'brakeman'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capybara'
  gem 'dotenv-rails', groups: %i[development test]
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'selenium-webdriver', '3.142.7'
  gem 'shoulda-matchers'
  gem 'site_prism'
  gem 'webmock'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen', '~> 3.5'
  gem 'rubocop', '~> 1.10.0'
  gem 'rubocop-govuk'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end
