module ApiHelpers
  def json
    JSON.parse(response.body)
  end

  def api_sign_in(user)
    token = AuthToken.encode(user_id: user.id)
    request.headers['Authorization'] = "bearer #{token}"
  end
end

RSpec.configure do |config|
  config.include ApiHelpers
end

