FactoryGirl.define do
  factory :subarticle do
    material
    description 'Papel Bond Tamaño Carta 75gr'
    unit 'Paquete'
    minimum 0
    status 1
  end
  trait :papel_carta do
    code { Faker::Number.number(7) }
    code_old { Faker::Number.number(5) }
    barcode { Faker::Number.number(7) }
    description 'PAPEL BOND TAMAÑO CARTA 75 GR. COLOR BLANCO'
    unit 'Paquete (500 hojas)'
    minimum 10
  end
end
