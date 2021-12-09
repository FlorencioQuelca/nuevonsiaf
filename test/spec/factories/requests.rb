FactoryGirl.define do
  factory :request do
    user
    association :admin, factory: :user, title: 'Encargado Almacenes'

    sequence(:nro_solicitud)
    status 'initiation' # Inicial
    delivery_date nil

    trait :anio_anterior do
      created_at '2015-04-13 13:13:13'
    end

    trait :julio do
      created_at '2016-07-05 13:50:45'
    end

    trait :agosto do
      created_at '2016-08-16 17:36:51'
    end

    trait :septiembre do
      created_at '2016-09-23 16:22:30'
    end

    trait :iniation do
      delivery_date ''
      status 'iniation' # inicial
    end

    trait :pending do
      delivery_date { created_at }
      status 'pending' # pendiente
    end

    trait :delivered do
      delivery_date { created_at }
      status 'delivered' # Entregado
    end

    factory :request_delivered, traits: [:delivered]
    factory :request_delivered_agosto, traits: [:agosto, :delivered]
  end
end
