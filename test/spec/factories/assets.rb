FactoryGirl.define do
  factory :asset do
    detalle  { Faker::Beer.name }
    medidas  { Faker::Beer.blg }
    material { Faker::Commerce.color }
    color    { Faker::Color.color_name }
    marca    { Faker::Vehicle.manufacture }
    modelo   { Faker::Code.asin }
    serie    { Faker::Code.isbn }

    ingreso
    auxiliary
    user
    ubicacion
  end
end
