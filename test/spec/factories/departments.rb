FactoryGirl.define do
  factory :department do
    sequence(:code)
    name { Faker::Address.city }

    building
  end
end
