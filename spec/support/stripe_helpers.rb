module StripeHelpers
  def add_credit_card(user)
    user.add_credit_card StripeMock.create_test_helper.generate_card_token
  end

  def reset_stripe_customer(user)
    user.instance_variable_set :@customer, nil
  end
end

RSpec.configure do |config|
  config.include StripeHelpers
end
