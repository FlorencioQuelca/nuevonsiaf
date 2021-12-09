FactoryGirl.define do
  factory :building do
    sequence(:code)
    name { Faker::Address.state }

    entity
  end
end
