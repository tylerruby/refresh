module ApiHelpers
  def json
    JSON.parse(response_body)
  end
end

RSpec.configure do |config|
  config.include ApiHelpers
end
