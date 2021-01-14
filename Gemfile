source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'metadata_presenter', '~> 0.1.7'
gem 'faraday'
gem 'faraday_middleware'
gem 'fb-jwt-auth', '0.5.0'
gem 'omniauth'
gem 'omniauth-auth0', '~> 2.4.1'
gem 'omniauth-rails_csrf_protection', '~> 0.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 5.1'
gem 'rails', '~> 6.1.1'
gem 'sass-rails', '>= 6'
gem 'tzinfo-data'
gem 'webpacker', '~> 5.2'

group :development, :test do
  gem 'brakeman'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara'
  gem 'dotenv-rails', groups: [:development, :test]
  gem 'rspec-rails'
  gem 'selenium-webdriver', '3.142.7'
  gem 'site_prism'
  gem 'webmock'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen', '~> 3.4'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end
