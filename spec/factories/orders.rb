FactoryGirl.define do
  factory :order do
    user
    status 1
    delivery_address "St. Nowhere"
    delivery_time 1
  end

end
