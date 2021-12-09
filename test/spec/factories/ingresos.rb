FactoryGirl.define do
  factory :ingreso do
    sequence(:numero)
    nota_entrega_fecha "12/03/2016"

    user
  end
end
