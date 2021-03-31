class AssertedIdentity
  include ActiveModel

  attr_accessor :uid, :provider, :name, :email

  def initialize(params = {})
    self.uid = params[:uid]
    self.provider = params[:provider]
    self.name = params[:name]
    self.email = params[:email]
  end

  def self.from_auth0_userinfo(userinfo = {})
    new(
      uid: userinfo['uid'],
      provider: userinfo['provider'],
      name: userinfo['info'].try(:[], 'name') || humanised_name(userinfo),
      email: userinfo['info'].try(:[], 'email')
    )
  end

  def self.humanised_name(userinfo)
    email_address = userinfo['info'].try(:[], 'email')
    email_address[/[^@]+/].split('.').map(&:capitalize).join(' ') if email_address
  end

  def to_identity
    Identity.new(
      uid: uid,
      provider: provider,
      name: name,
      email: email
    )
  end
end
