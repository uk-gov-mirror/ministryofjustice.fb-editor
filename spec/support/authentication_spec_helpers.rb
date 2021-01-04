module AuthenticationSpecHelpers
  def auth0_userinfo(attributes={})
    user_info = {
      "provider"=>"auth0",
      "uid"=>"google-oauth2|012345678900123456789",
      "info"=> {
        "name"=> "John Smith",
        "email"=> "john.smith@test-only.justice.gov.uk"
      }.merge(attributes.stringify_keys)
    }
    OmniAuth::AuthHash.new(user_info)
  end

  def stub_auth0_userinfo(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:auth0, auth0_userinfo(user))
  end

  def stub_cookie_variable!(name, value)
    cookie_jar = Capybara.current_session.driver.browser.current_session\
                         .instance_variable_get(:@rack_mock_session)\
                         .cookie_jar
    cookie_jar[:"stub_#{name.to_s}"] = value
  end

  def clear_session!
    stub_cookie_variable!(:user_id, nil)
  end

  def logout
    click_on 'Sign Out'
    clear_session!
  end

  def login_as!(user)
    stub_auth0_userinfo(user)
    home.load
    home.sign_in.click
  end

  def home_page
    HomePage.new
  end
end
