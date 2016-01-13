FactoryGirl.define do
  factory :order do
    user
    status 1
    delivery_address "St. Nowhere"
    stripe_token { StripeMock.create_test_helper.generate_card_token }
  end
end
