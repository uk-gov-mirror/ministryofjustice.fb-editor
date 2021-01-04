feature 'Authentication' do
  let(:home) { HomePage.new }
  let(:authentication) { AuthenticationPage.new }

  scenario 'when user is digital justice' do
    login_as!(name: 'Grogu', email: 'grogu@digital.justice.gov.uk')
    expect(page.current_url).to_not include('signup_error')
    expect(User.count).to be(1)
  end

  scenario 'when user re-login' do
    login_as!(name: 'Grogu', email: 'grogu@digital.justice.gov.uk')
    logout
    login_as!(name: 'Grogu', email: 'grogu@digital.justice.gov.uk')
    expect(User.count).to be(1)
  end

  scenario 'when user is not digital justice' do
    login_as!(name: 'Grogu', email: 'grogu@jedi.temple.uk')
    expect(page.current_url).to include('signup_not_allowed')
    expect(User.count).to be_zero
  end
end
