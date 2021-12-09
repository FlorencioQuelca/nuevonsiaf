require 'spec_helper'

RSpec.describe Subarticle, type: :model do

  context 'creación' do
    before :each do
      # Creación de materiales
      @material1 = FactoryGirl.create(:material, :papel)
      @material2 = FactoryGirl.create(:material, :publicidad)
      @material3 = FactoryGirl.create(:material, :limpieza)

      # Creación de subartículos
      @subarticle1 = FactoryGirl.create(:subarticle, material: @material1)
      @subarticle2 = FactoryGirl.create(:subarticle, material: @material1)
      @subarticle3 = FactoryGirl.create(:subarticle, material: @material2)
      @subarticle4 = FactoryGirl.create(:subarticle, material: @material2)
      @subarticle5 = FactoryGirl.create(:subarticle, material: @material3)

      FactoryGirl.create_list(:subarticle, 25, material: @material3)
    end

    it 'cantidad' do
      expect(Subarticle.count).to eq(30)
    end

    it 'generación códigos' do
      expect(@subarticle1.code).to eq(321001)
      expect(@subarticle2.code).to eq(321002)
      expect(@subarticle3.code).to eq(255001)
      expect(@subarticle4.code).to eq(255002)
      expect(@subarticle5.code).to eq(391001)
      expect(Subarticle.last.code).to eq(3910026)
    end

    it 'saldo inicial' do
      FactoryGirl.create(:entry_subarticle, :cien, subarticle: @subarticle1)
      expect(@subarticle1.stock).to eq(100)
      expect(@subarticle2.stock).to eq(0)
    end
  end

  context 'fechas' do
    before :each do
      @desde = '2016-07-01'.to_date
      @hasta = '2016-10-11'.to_date

      # Grupo contable
      material = FactoryGirl.create(:material, :papel)
      FactoryGirl.create_list(:subarticle, 5, material: material)

      # subartículos
      subarticle_1 = Subarticle.first
      subarticle_1000 = Subarticle.second
      subarticle_10 = Subarticle.third
      subarticle_400 = Subarticle.fourth
      subarticle_100 = Subarticle.fifth

      # entradas: saldos iniciales
      FactoryGirl.create(:entry_subarticle_enero_1, subarticle: subarticle_1)
      FactoryGirl.create(:entry_subarticle_mayo_1000, subarticle: subarticle_1000)
      FactoryGirl.create(:entry_subarticle_junio_10, subarticle: subarticle_10)
      FactoryGirl.create(:entry_subarticle_julio_400, subarticle: subarticle_400)
      FactoryGirl.create(:entry_subarticle_agosto_100, subarticle: subarticle_100)

      # salidas mediante solicitudes
      request = FactoryGirl.create(:request_delivered_agosto)
      request.subarticle_requests << create(:subarticle_request_delivered_1, subarticle: subarticle_1)
      request.subarticle_requests << create(:subarticle_request_delivered_10, subarticle: subarticle_1000)
      request.subarticle_requests << create(:subarticle_request_delivered_9, subarticle: subarticle_10)
      request.subarticle_requests << create(:subarticle_request_delivered_400, subarticle: subarticle_400)
      request.subarticle_requests << create(:subarticle_request_delivered_100, subarticle: subarticle_100)
    end

    it 'con saldo' do
      expect(Subarticle.con_saldo(@desde).length).to eq(4)
    end

    it 'con transacciones' do
      expect(Subarticle.con_movimientos_en(@desde, @hasta).length).to eq(2)
    end

    it 'con saldo y movimientos' do
      expect(Subarticle.con_saldo_y_movimientos_en(@desde, @hasta).length).to eq(5)
    end
  end

  context 'verificacion de stock' do
    let(:papel)              { FactoryGirl.create :material, :papel }
    let(:entry_subarticle_1) { FactoryGirl.create :entry_subarticle_junio_10 }
    let(:entry_subarticle_2) { FactoryGirl.create :entry_subarticle_agosto_100 }
    let(:subarticulo)        { FactoryGirl.create :subarticle, material: papel, entry_subarticles: [entry_subarticle_1, entry_subarticle_2] }

    it 'subarticulo valido' do
      expect(subarticulo).to be_valid
      expect(subarticulo.entry_subarticles.size).to eq(2)
    end

    it 'saldo inicial' do
      expect(subarticulo.stock).to eq(subarticulo.entry_subarticles_exist.inject(0){ |suma, es| suma + es.stock })
    end
  end
end
