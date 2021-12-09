FactoryGirl.define do
  factory :entity do
    sequence(:code)
    name    { Faker::Address.country }
    acronym { Faker::Address.country_code }
  end
end
