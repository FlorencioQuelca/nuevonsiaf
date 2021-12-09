FactoryGirl.define do
  factory :user do
    sequence(:code)
    name     { Faker::Name.name_with_middle }
    title    { Faker::Name.title }
    ci       { Faker::Number.number(10) }
    email    { Faker::Internet.email }
    username { Faker::Internet.user_name(4) }
    password { Faker::Internet.password(6) }
    phone    { Faker::Number.number(7) }
    mobile   { Faker::Number.number(8) }
    role nil

    department

    trait :super_admin do # Super administrador
      role 'super_admin'
    end

    trait :activos do # Activos fijos
      role 'admin'
    end

    trait :almacenes do # Almacenes
      role 'admin_store'
    end

    factory :user_super_admin, traits: [:super_admin]
    factory :user_activos, traits: [:activos]
    factory :user_almacenes, traits: [:almacenes]
  end
end
