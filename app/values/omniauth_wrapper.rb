class OmniauthWrapper
  attr_accessor :provider, :uid, :email

  def initialize(oauth)
    self.provider = oauth.provider
    self.uid = oauth.uid
    self.email = oauth.info.email
  end
end
