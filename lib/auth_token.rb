require 'jwt'

class AuthToken
  def self.encode(data)
    payload = {
      exp: 1.month.from_now.to_i,
      data: data
    }
    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end

  def self.decode(token)
    JWT.decode(token, Rails.application.secrets.secret_key_base)[0]['data']
  end
end
