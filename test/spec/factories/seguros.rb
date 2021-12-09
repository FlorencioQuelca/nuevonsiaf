FactoryGirl.define do
  factory :seguro do
    supplier_id "1"
    user_id "2"
    numero_contrato "contrato vigente"
    factura_numero "1231321"
    factura_autorizacion "212313a"
    factura_fecha "2016-07-14"
    state "asegurado"
    trait :vigente do
      fecha_inicio_vigencia "2016-07-14 12:00"
      fecha_fin_vigencia "2016-11-14 12:00"
    end
    trait :no_vigente do
      fecha_inicio_vigencia "2015-07-14 12:00"
      fecha_fin_vigencia "2015-11-14 12:00"
    end
    baja_logica false
  end
end
