FactoryGirl.define do
  factory :account do
    sequence(:code)
    name "ACTIVOS MUSEOLOGICOS Y CULTURALES"
    vida_util 0
    depreciar false
    actualizar false
  end
end
