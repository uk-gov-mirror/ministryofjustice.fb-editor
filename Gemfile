source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.9'

# Metadata presenter - if you need to be on development you can uncomment
# one of these lines:
# gem 'metadata_presenter',
#     github: 'ministryofjustice/fb-metadata-presenter',
#     branch: 'test-footer-partial'
# gem 'metadata_presenter', path: '../fb-metadata-presenter'
gem 'metadata_presenter', '3.4.28'

gem 'activerecord-session_store', '~> 2.2.0'
gem 'administrate', '~> 1.0'
gem 'aws-sdk-s3', '~> 1.208.0'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'csv'
gem 'daemons'
gem 'delayed_job_active_record'
gem 'dotenv', '3.2.0'
gem 'faraday', '~> 2.14.3'
gem 'fb-jwt-auth', '0.10.0'
gem 'govspeak', '~> 7.1'
gem 'govuk-components', '~> 6.4'
gem 'govuk_design_system_formbuilder'
gem 'govuk_notify_rails', '~> 3.0.0'
gem 'hashie'
gem 'image_processing', '~> 1.2'
gem 'omniauth-auth0', '~> 3.1.0'
gem 'omniauth-rails_csrf_protection', '~> 2.0.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 6.4'
gem 'rack', '3.2.6'
gem 'rails', '~> 8.1.3.1'
# Use Redis for Action Cable
gem 'redis', '~> 4.0'
gem 'sass-rails', '>= 6'
gem 'sentry-delayed_job', '~> 5.14'
gem 'sentry-rails', '~> 5.28.1'
gem 'sentry-ruby', '~> 5.14'
gem 'shakapacker', '~> 10.3'
gem 'turbo-rails', '~> 2.0.0'
gem 'tzinfo-data'

group :development, :test do
  gem 'axe-core-rspec'
  gem 'brakeman'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capybara'
  gem 'capybara_accessible_selectors', git: 'https://github.com/citizensadvice/capybara_accessible_selectors', tag: 'v0.11.0'
  gem 'dotenv-rails', groups: %i[development test]
  gem 'factory_bot_rails', '~> 6.5.0'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  gem 'selenium-webdriver', '4.48.0'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'site_prism', '~> 6.0'
  gem 'webmock', '~> 3.25.2'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen', '~> 3.8'
  gem 'rubocop'
  gem 'rubocop-govuk', '~> 5.2.0'
  gem 'ruby-lsp'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1.0'
  gem 'web-console', '>= 3.3.0'
end
