FactoryGirl.define do
  factory :material do
    sequence(:code)
    description 'Descripción de la cuenta contable'
    trait :publicidad do
      code '25500'
      description 'Publicidad'
    end
    trait :papel do
      code '32100'
      description 'Papel'
    end
    trait :limpieza do
      code '39100'
      description 'Limpieza'
    end
  end
end
