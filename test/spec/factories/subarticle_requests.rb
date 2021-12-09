FactoryGirl.define do
  factory :subarticle_request do
    subarticle
    request

    amount 0
    amount_delivered 0
    total_delivered 0
    invalidate false

    trait :iniation do # inicial
      amount_delivered { 0 }
      total_delivered { 0 }
    end

    trait :delivered do # entregado
      amount_delivered { amount }
      total_delivered { amount }
    end

    trait :cantidad_1 do
      amount 1
    end

    trait :cantidad_10 do
      amount 10
    end

    trait :cantidad_9 do
      amount 9
    end

    trait :cantidad_100 do
      amount 100
    end

    trait :cantidad_250 do
      amount 250
    end

    trait :cantidad_400 do
      amount 400
    end

    factory :subarticle_request_delivered_1, traits: [:cantidad_1, :delivered]
    factory :subarticle_request_delivered_10, traits: [:cantidad_10, :delivered]
    factory :subarticle_request_delivered_9, traits: [:cantidad_9, :delivered]
    factory :subarticle_request_delivered_400, traits: [:cantidad_400, :delivered]
    factory :subarticle_request_delivered_100, traits: [:cantidad_100, :delivered]
    factory :subarticle_request_delivered_250, traits: [:cantidad_250, :iniation]
  end
end
