class OmniauthWrapper
  attr_accessor :provider, :uid, :email, :avatar

  def initialize(oauth)
    self.provider = oauth.provider
    self.uid = oauth.uid
    self.email = oauth.info.email
    self.avatar = oauth.info.image
  end
end
