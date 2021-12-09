FactoryGirl.define do
  factory :supplier do
    name     { Faker::Company.name }
    nit      { Faker::Company.swedish_organisation_number }
    telefono { Faker::PhoneNumber.phone_number }
    contacto { Faker::Name.name }
  end
end
