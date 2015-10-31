FactoryGirl.define do
  factory :address do
    address "4th Av."
    city
    addressable nil

    factory :far_far_away do
      address "Far Far Away"
    end
  end
end
