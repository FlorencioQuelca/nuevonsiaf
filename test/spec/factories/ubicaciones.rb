FactoryGirl.define do
  factory :ubicacion do
    abreviacion { Faker::Address.country_code }
    descripcion { Faker::Address.country }
  end
end
