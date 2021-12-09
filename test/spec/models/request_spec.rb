require 'spec_helper'

RSpec.describe Request, type: :model do
  context 'Consultas' do
    before :each do
      # Creación de materiales
      @request1 = FactoryGirl.create(:request, :julio)
      @request2 = FactoryGirl.create(:request, :agosto)
      @request3 = FactoryGirl.create(:request, :septiembre)
      @request4 = FactoryGirl.create(:request, :anio_anterior)
    end

    it 'de la gestión' do
      expect(Request.del_anio_por_fecha_creacion("2016-08-13".to_datetime).size).to eq(3)
    end

    it 'mayor a la fecha de creacion' do
      expect(Request.mayor_a_fecha_creacion("2016-07-08".to_datetime).size).to eq(2)
    end

    it 'menor igual a la fecha de creacion' do
      expect(Request.menor_igual_a_fecha_creacion("2016-07-05".to_datetime).size).to eq(2)
    end

    it 'con fecha de creación' do
      expect(Request.con_fecha_creacion.size).to eq(4)
    end

    it 'con nro solicitud' do
      expect(Request.con_nro_solicitud.size).to eq(4)
    end
  end

  context 'generacion de números de solicitud' do
    before :each do
      # Creación de materiales
      @request1 = FactoryGirl.create(:request, :julio, nro_solicitud: 10)
      @request2 = FactoryGirl.create(:request, :agosto, nro_solicitud: 11)
      @request3 = FactoryGirl.create(:request, :septiembre, nro_solicitud: 12)
      @request3 = FactoryGirl.create(:request, :anio_anterior)
    end

    it 'posterior a la ultima fecha' do
      expect(Request.obtiene_siguiente_numero_solicitud("23/09/2016".to_datetime)).to eq({ codigo_numerico: 13 })
    end

    it 'entre 2 fechas' do
      expect(Request.obtiene_siguiente_numero_solicitud("01/08/2016".to_datetime)).to eq({ tipo_respuesta: "confirmacion",
                                                                                           numero: "10-A",
                                                                                           codigo_numerico: 10,
                                                                                           codigo_alfabetico: "A",
                                                                                           ultima_fecha: "23/09/2016" })
    end

    it 'anterior a todas las fechas' do
      expect(Request.obtiene_siguiente_numero_solicitud("01/04/2016".to_datetime)).to eq({ codigo_numerico: 9 })
    end

    it 'en una gestion posterior a la actual' do
      expect(Request.obtiene_siguiente_numero_solicitud("01/04/2016".to_datetime)).to eq({ codigo_numerico: 9 })
    end

  end

  context 'solicitud de materiales con stock disponible' do
    let(:papel)                 { FactoryGirl.create :material, :papel }
    let(:entry_subarticle_1)    { FactoryGirl.create :entry_subarticle_junio_10 }
    let(:entry_subarticle_2)    { FactoryGirl.create :entry_subarticle_agosto_100 }
    let(:entry_subarticle_3)    { FactoryGirl.create :entry_subarticle_agosto_100 }
    let(:entry_subarticle_4)    { FactoryGirl.create :entry_subarticle_agosto_100 }
    let(:subarticulo)           { FactoryGirl.create :subarticle, material: papel, entry_subarticles: [entry_subarticle_1, entry_subarticle_2, entry_subarticle_3, entry_subarticle_4] }
    let(:solicitud_subarticulo) { FactoryGirl.create :subarticle_request_delivered_250, subarticle: subarticulo }
    let(:solicitud)             { FactoryGirl.create :request, :septiembre, :iniation, nro_solicitud: 12, subarticle_requests: [solicitud_subarticulo] }

    context 'datos validos' do
      it 'solicitud valida' do
        expect(solicitud).to be_valid
        expect(solicitud.subarticle_requests).to eq([solicitud_subarticulo])
      end

      it 'subarticulo valido' do
        expect(subarticulo).to be_valid
        expect(subarticulo.entry_subarticles.size).to eq(4)
        expect(subarticulo.entry_subarticles).to eq([entry_subarticle_1, entry_subarticle_2, entry_subarticle_3, entry_subarticle_4] )
      end

      it 'saldo inicial del subarticulo' do
        expect(subarticulo.stock).to eq(subarticulo.entry_subarticles_exist.inject(0){ |suma, es| suma + es.stock })
      end
    end

    context 'entregando los subarticulos' do
      it 'saldo posterior a la entrega de subarticulos' do
        request_params = {
          'status' => 'pending',
          'subarticle_requests_attributes' => {
            '0' => {
              'id' => solicitud_subarticulo.id,
              'amount_delivered' => '250'
            }
          }
        }
        expect(solicitud.status).to eq('iniation')
        solicitud.entregar_subarticulos(request_params)
        expect(subarticulo.stock).to eq(60)
        expect(subarticulo.entry_subarticles_exist.inject(0){ |suma, es| suma + es.stock }).to eq(60)
        solicitud_subarticulo_auxiliar = SubarticleRequest.find(solicitud_subarticulo.id)
        expect(solicitud_subarticulo_auxiliar.amount_delivered).to eq(250)
        expect(solicitud_subarticulo_auxiliar.total_delivered).to eq(250)
        solicitud_auxiliar = Request.find(solicitud.id)
        expect(solicitud_auxiliar.status).to eq('delivered')
      end
    end
  end

  context 'solicitud de materiales sin stock disponible' do
    let(:papel)                 { FactoryGirl.create :material, :papel }
    let(:entry_subarticle_1)    { FactoryGirl.create :entry_subarticle_junio_10 }
    let(:entry_subarticle_2)    { FactoryGirl.create :entry_subarticle_agosto_100 }
    let(:subarticulo)           { FactoryGirl.create :subarticle, material: papel, entry_subarticles: [entry_subarticle_1, entry_subarticle_2] }
    let(:solicitud_subarticulo) { FactoryGirl.create :subarticle_request_delivered_250, subarticle: subarticulo }
    let(:solicitud)             { FactoryGirl.create :request, :septiembre, :iniation, nro_solicitud: 12, subarticle_requests: [solicitud_subarticulo] }

    context 'datos validos' do
      it 'solicitud valida' do
        expect(solicitud).to be_valid
        expect(solicitud.subarticle_requests).to eq([solicitud_subarticulo])
      end

      it 'subarticulo valido' do
        expect(subarticulo).to be_valid
        expect(subarticulo.entry_subarticles.size).to eq(2)
        expect(subarticulo.entry_subarticles).to eq([entry_subarticle_1, entry_subarticle_2] )
      end

      it 'saldo inicial del subarticulo' do
        expect(subarticulo.stock).to eq(subarticulo.entry_subarticles_exist.inject(0){ |suma, es| suma + es.stock })
      end
    end

    context 'entregando los subarticulos' do
      it 'saldo posterior a la entrega de subarticulos' do
        request_params = {"status"=>"pending", "subarticle_requests_attributes"=>{"0"=>{"id"=>solicitud_subarticulo.id, "amount_delivered"=>"250"}}}
        expect(solicitud.status).to eq("iniation")
        solicitud.entregar_subarticulos(request_params)
        expect(subarticulo.stock).to eq(110)
        expect(subarticulo.entry_subarticles_exist.inject(0){ |suma, es| suma + es.stock }).to eq(110)
        solicitud_subarticulo_auxiliar = SubarticleRequest.find(solicitud_subarticulo.id)
        expect(solicitud_subarticulo_auxiliar.amount_delivered).to eq(0)
        expect(solicitud_subarticulo_auxiliar.total_delivered).to eq(0)
        solicitud_auxiliar = Request.find(solicitud.id)
        expect(solicitud_auxiliar.status).to eq("iniation")
      end
    end
  end

  context 'solicitud de materiales con stock disponible con cantidad a entregar 0' do
    let(:papel) { FactoryGirl.create :material, :papel }
    let(:entry_subarticle_1) { FactoryGirl.create :entry_subarticle_junio_10 }
    let(:entry_subarticle_2) { FactoryGirl.create :entry_subarticle_agosto_100 }
    let(:entry_subarticle_3) { FactoryGirl.create :entry_subarticle_agosto_100 }
    let(:entry_subarticle_4) { FactoryGirl.create :entry_subarticle_agosto_100 }
    let(:subarticulo) { FactoryGirl.create :subarticle, material: papel, entry_subarticles: [entry_subarticle_1, entry_subarticle_2, entry_subarticle_3, entry_subarticle_4] }
    let(:solicitud_subarticulo) { FactoryGirl.create :subarticle_request_delivered_250, subarticle: subarticulo }
    let(:solicitud)             { FactoryGirl.create :request, :septiembre, :iniation, nro_solicitud: 12, subarticle_requests: [solicitud_subarticulo] }

    context 'datos validos' do
      it 'solicitud valida' do
        expect(solicitud).to be_valid
        expect(solicitud.subarticle_requests).to eq([solicitud_subarticulo])
      end

      it 'subarticulo valido' do
        expect(subarticulo).to be_valid
        expect(subarticulo.entry_subarticles.size).to eq(4)
        expect(subarticulo.entry_subarticles).to eq([entry_subarticle_1, entry_subarticle_2, entry_subarticle_3, entry_subarticle_4] )
      end

      it 'saldo inicial del subarticulo' do
        entry_subarticles = subarticulo.entry_subarticles_exist
        sumatoria = entry_subarticles.inject(0) { |s, e| s + e.stock}
        expect(subarticulo.stock).to eq(sumatoria)
      end
    end

    context 'entregando los subarticulos' do
      it 'saldo posterior a la entrega de subarticulos' do
        request_params = {
          'status' => 'pending',
          'subarticle_requests_attributes' => {
            '0' => {
              'id' => solicitud_subarticulo.id,
              'amount_delivered' => '0'
            }
          }
        }
        expect(solicitud.status).to eq('iniation')
        solicitud.entregar_subarticulos(request_params)
        expect(subarticulo.stock).to eq(310)
        suma_stocks = subarticulo.entry_subarticles_exist.inject(0){ |s, es| s + es.stock}
        expect(suma_stocks).to eq(310)
        solicitud_subart_aux = SubarticleRequest.find(solicitud_subarticulo.id)
        expect(solicitud_subart_aux.amount_delivered).to eq(0)
        expect(solicitud_subart_aux.total_delivered).to eq(0)
        solicitud_auxiliar = Request.find(solicitud.id)
        expect(solicitud_auxiliar.status).to eq('canceled')
      end
    end
  end

  context 'Generación automática de codigos de activos' do
    it 'Sin ningún activo' do
      expect(Asset.obtiene_siguiente_codigo).to eq(1)
    end

    it 'Con activos' do
      FactoryGirl.create :asset
      FactoryGirl.create :asset
      FactoryGirl.create :asset
      FactoryGirl.create :asset
      a = FactoryGirl.create :asset
      expect(a.code).to eq(5)
    end
  end
end
