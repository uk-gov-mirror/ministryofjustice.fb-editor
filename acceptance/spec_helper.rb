require 'capybara/rspec'
require 'selenium/webdriver'
require 'site_prism'
require 'dotenv'
Dotenv.load('.env.acceptance_tests')
require 'rails/all'
require 'metadata_presenter'

Dir[File.join('acceptance', 'pages', '*')].each { |f| require File.expand_path(f) }
Dir[File.join('acceptance', 'support', '*')].each { |f| require File.expand_path(f) }

puts "Accessing Editor in: #{ENV['ACCEPTANCE_TESTS_EDITOR_APP']}"

RSpec.configure do |config|
  config.before(:all) do
    WebMock.allow_net_connect! if defined? WebMock
  end

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.after do |example_group|
    if example_group.exception.present?
      puts editor.text
    end
  end

  config.include TestHelpers
  config.include CommonSteps
end
