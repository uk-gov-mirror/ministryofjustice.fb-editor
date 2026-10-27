require_relative '../spec_helper'

feature 'Visiting admin pages' do
  let(:editor) { EditorApp.new }
  let(:admin_pages) do
    %w(
      admin
      admin/overviews
      admin/questionnaires
      admin/announcements
      admin/services
      admin/users
      admin/publish_services
    )
  end

  scenario 'when not logged in' do
    admin_pages.each do |path|
      given_I_visit_an_admin_page(path)
      then_I_should_be_redirected_to_login
    end
  end

  # acceptance test user does not have permission to visit admin dashboards
  scenario 'when logged in' do
    given_I_am_logged_in
    then_I_should_see_the_admin_link
    admin_pages.each do |path|
      given_I_visit_an_admin_page(path)
      then_I_should_be_redirected_to_the_page(path)
    end
  end

  def given_I_visit_an_admin_page(path)
    visit(File.join(ENV['ACCEPTANCE_TESTS_EDITOR_APP'], path))
  end

  def then_I_should_be_redirected_to_login
    expect(page.current_path).to eq('/')
    expect(page.title).to eq(I18n.t('home.show.title'))
    expect(page).to have_content(I18n.t('home.show.sign_in'))
  end

  def then_I_should_be_redirected_to_the_page(path)
    expect(page.current_path).to eq("/#{path}")
  end

  def then_I_should_see_the_admin_link
    expect(page).to have_content(I18n.t('partials.header.admin'))
  end
end
