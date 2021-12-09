require 'spec_helper'

RSpec.describe Seguro, type: :model do

  context "cuando tenemos 2 registros de seguros uno vigente y otro no vigente" do
    before :each do
      @seguro_vigente = FactoryGirl.create(:seguro, :vigente)
      @seguro_no_vigente = FactoryGirl.create(:seguro, :no_vigente)
    end

    it "verificacion la validacion al crear un seguros" do
      expect(@seguro_vigente).to be_valid, "seguro valido"
      expect(@seguro_no_vigente).to be_valid, "seguro valido"
    end

    it "verificando antes de la fecha inicio de vigencia" do
      expect(Seguro.vigentes("13-07-2016 12:00".to_datetime)).to be_empty, "no existe seguros validos"
    end

    it "verificando en la fecha inicio de vigencia" do
      expect(Seguro.vigentes("14-07-2016 12:00".to_datetime)).not_to be_empty, "existe seguros validos"
    end

    it "verificando antes de la fecha fin de vigencia" do
      expect(Seguro.vigentes("14-07-2016 12:00".to_datetime)).not_to be_empty
    end

    it "verificando en la fecha fin de vigencia" do
      expect(Seguro.vigentes("14-11-2016 12:00".to_datetime)).not_to be_empty
    end

    it "verificando posterior a la fecha fin de vigencia" do
      expect(Seguro.vigentes("15-11-2016 12:00".to_datetime)).to be_empty
    end
  end

  context "cuando tenemos 2 seguros uno vigente y otro no vigente" do
    before :each do
      @seguro_vigente = FactoryGirl.create(:seguro, :vigente)
      @seguro_no_vigente = FactoryGirl.create(:seguro, :no_vigente)

      @activo_1 = FactoryGirl.create(:asset)
      @activo_2 = FactoryGirl.create(:asset)
      @activo_3 = FactoryGirl.create(:asset)
      @activo_4 = FactoryGirl.create(:asset)
      @activo_5 = FactoryGirl.create(:asset)
      @activo_6 = FactoryGirl.create(:asset)
      @activo_7 = FactoryGirl.create(:asset)
      @activo_8 = FactoryGirl.create(:asset)

      @seguro_vigente.assets << @activo_1
      @seguro_vigente.assets << @activo_2
      @seguro_vigente.assets << @activo_3
      @seguro_vigente.assets << @activo_4
      @seguro_vigente.assets << @activo_5
      @seguro_no_vigente.assets << @activo_6
      @seguro_no_vigente.assets << @activo_7
      @seguro_no_vigente.assets << @activo_8
    end

    it "verificando la existencia de activos sin seguro" do
      Timecop.travel("13-08-2016 13:00".to_datetime)
      expect(Asset.sin_seguro_vigente.size).to eq(3), "existen 3 activos sin seguro"
    end

    it "verificando la no existencia de activos sin seguro" do
      Timecop.freeze("20-08-2016 12:00".to_datetime)
      @seguro_vigente.assets << @activo_6
      @seguro_vigente.assets << @activo_7
      @seguro_vigente.assets << @activo_8
      expect(Asset.sin_seguro_vigente).to be_empty
      Timecop.return
    end

    it "Alerta de expiración antes de los 90 dias" do
      Timecop.freeze(@seguro_vigente.fecha_fin_vigencia - 91.days)
      expect(@seguro_vigente.alerta_expiracion).to eq({
                                                        mensaje: "El seguro vence el 14 de noviembre de 2016 a las 12:00.",
                                                        tipo: "success",
                                                        parpadeo: false
                                                      })
      Timecop.return
    end

    it "Alerta de expiración antes de los 30 dias" do
      Timecop.freeze(@seguro_vigente.fecha_fin_vigencia - 31.days)
      expect(@seguro_vigente.alerta_expiracion).to eq({
                                                        mensaje: "El seguro vence el 14 de noviembre de 2016 a las 12:00.",
                                                        tipo: "warning",
                                                        parpadeo: false
                                                      })
      Timecop.return    end

    it "Alerta de expiración antes de los 7 dias" do
      Timecop.freeze(@seguro_vigente.fecha_fin_vigencia - 8.days)
      expect(@seguro_vigente.alerta_expiracion).to eq({
                                                        mensaje: "El seguro vence el 14 de noviembre de 2016 a las 12:00.",
                                                        tipo: "danger",
                                                        parpadeo: false
                                                      })
      Timecop.return
    end

    it "Alerta de expiración dentro de los 7 dias" do
      Timecop.freeze(@seguro_vigente.fecha_fin_vigencia - 5.days)
      expect(@seguro_vigente.alerta_expiracion).to eq({
                                                        mensaje: "El seguro vence el 14 de noviembre de 2016 a las 12:00.",
                                                        tipo: "danger",
                                                        parpadeo: true
                                                      })
      Timecop.return
    end
  end

  context "Probando la vigencia de un seguro" do
    let(:seguro) { FactoryGirl.create :seguro, { fecha_inicio_vigencia: "01-01-2015 12:00", fecha_fin_vigencia:"31-12-2015 12:01" } }

    it "Fecha antes de la fecha de inicio de vigencia" do
      Timecop.freeze("13-04-2014 12:00")
      expect(seguro.vigente?).to eq(false)
      Timecop.return
    end

    it "Fecha en la fecha de inicio de vigencia" do
      Timecop.freeze("01-01-2015 12:00")
      expect(seguro.vigente?).to eq(true)
      Timecop.return
    end

    it "Fecha en la fecha de fin de vigencia" do
      Timecop.freeze("31-12-2015 08:00")
      expect(seguro.vigente?).to eq(true)
      Timecop.return
    end

    it "Fecha posterior a la fecha de fin de vigencia" do
      Timecop.freeze("02-01-2016 13:00")
      expect(seguro.vigente?).to eq(false)
      Timecop.return
    end

    it "Fecha y hora antes de la fecha y hora fin de vigencia" do
      Timecop.freeze("31-12-2015 12:00")
      expect(seguro.vigente?).to eq(true)
      Timecop.return
    end

    it "Fecha y hora igual de la fecha fin de vigencia" do
      Timecop.freeze("31-12-2015 12:01")
      expect(seguro.vigente?).to eq(true)
      Timecop.return
    end

    it "Fecha y hora despues de la fecha fin de vigencia" do
      Timecop.freeze("31-12-2015 12:02")
      expect(seguro.vigente?).to eq(false)
      Timecop.return
    end
  end

end
