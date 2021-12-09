FactoryGirl.define do
  factory :entry_subarticle do
    subarticle
    amount 0
    unit_cost 0
    total_cost 0
    date Date.today

    trait :cien do
      amount 100
      unit_cost 2
      total_cost 200
    end

    trait :trescientos do
      amount 300
      unit_cost 1.8
      total_cost 5400
    end

    trait :enero do
      amount 1
      unit_cost 2050.66
      total_cost 2050.66
      date '2016-01-04'
    end

    trait :mayo do
      amount 1000
      unit_cost 0.5
      total_cost 500
      date '2016-05-03'
    end

    trait :junio do
      amount 10
      unit_cost 200
      total_cost 2000
      date '2016-06-01'
    end

    trait :julio do
      amount 400
      unit_cost 6.5678
      total_cost 2627.12
      date '2016-07-01'
    end

    trait :agosto do
      amount 100
      unit_cost 16.88
      total_cost 1688.0
      date '2016-08-08'
    end

    factory :entry_subarticle_enero_1, traits: [:enero]
    factory :entry_subarticle_mayo_1000, traits: [:mayo]
    factory :entry_subarticle_junio_10, traits: [:junio]
    factory :entry_subarticle_julio_400, traits: [:julio]
    factory :entry_subarticle_agosto_100, traits: [:agosto]
  end
end
