Capybara.register_driver :selenium do |app|
  chrome_options = Selenium::WebDriver::Chrome::Options.new.tap do |o|
    o.add_argument '--headless'
    o.add_argument '--no-sandbox'
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_options)
end

Capybara.default_driver = :selenium
Capybara.current_session.driver.reset!
Capybara.default_host = ENV['ACCEPTANCE_TESTS_EDITOR_APP']
Capybara.app_host = ENV['ACCEPTANCE_TESTS_EDITOR_APP']
Capybara.run_server = false
