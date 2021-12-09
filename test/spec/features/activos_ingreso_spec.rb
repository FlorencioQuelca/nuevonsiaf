require 'rails_helper'

describe 'Activos fijos', js: true do
  def fill_factura(field)
    fill_in "#{field}_numero", with: Faker::Number.number(10)
    fill_in "#{field}_autorizacion", with: Faker::Number.number(10)
    fill_in "#{field}_fecha", with: I18n.l(Faker::Date.backward(10))
    presionar_enter("#{field}_fecha")
  end

  def fill_nota_de_entrega(field)
    fill_in "#{field}_numero", with: Faker::Number.number(5)
    fill_in "#{field}_fecha", with: I18n.l(Faker::Date.backward(10))
    presionar_enter("#{field}_fecha")
  end

  def fill_c31(field)
    fill_in "#{field}_numero", with: Faker::Number.number(3)
    fill_in "#{field}_fecha", with: I18n.l(Faker::Date.backward(20))
    presionar_enter("#{field}_fecha")
  end

  let(:usuario_activos) { create(:user_activos) }

  before { iniciar_sesion(usuario_activos) }
  after  { cerrar_sesion(usuario_activos) }

  context 'listado de notas de ingreso' do
    it 'sin ninguna nota de ingreso' do
      visit ingresos_path

      expect(page).to have_content('Mostrando 0 al 0 de 0 registros')
    end
  end

  context 'creación notas de ingreso' do
    let(:proveedor) { create :supplier }
    let!(:activo1)  { create :asset, user: usuario_activos, ingreso: nil }
    let!(:activo2)  { create :asset, user: usuario_activos, ingreso: nil }
    let!(:activo3)  { create :asset, user: usuario_activos, ingreso: nil }

    it 'selección de proveedor' do
      visit new_ingreso_path

      fill_autocomplete 'proveedor', with: proveedor.name
      fill_in 'code', with: activo1.code; click_on 'Buscar'; wait_for_ajax

      click_on 'Guardar'

      expect(page).to have_content('Ingreso de Activos Fijos Nro')
      expect(page).to have_content('Datos proveedor')
      expect(page).to have_content(proveedor.name)
      expect(page).to have_content('Firma Activos Fijos')
      expect(Ingreso.count).to eq(1)
      expect(Ingreso.first.assets.count).to eq(1)
    end

    it 'llenado de factura, nota de entrega, c31, y activos fijos' do
      visit new_ingreso_path

      fill_autocomplete 'proveedor', with: proveedor.name
      fill_factura 'factura'
      fill_nota_de_entrega 'nota_entrega'
      fill_c31 'c31'

      fill_in 'code', with: activo1.code; click_on 'Buscar'; wait_for_ajax
      fill_in 'code', with: activo2.code; click_on 'Buscar'; wait_for_ajax
      fill_in 'code', with: activo3.code; click_on 'Buscar'; wait_for_ajax

      click_on 'Guardar'

      expect(page).to have_content('Ingreso de Activos Fijos Nro. 1')
      expect(page).to have_content(proveedor.name)
      expect(page).to have_content(proveedor.nit)
      expect(page).to have_content('Factura No')
      expect(page).to have_content('Autorización')
      expect(page).to have_content('Fecha de factura')
      expect(page).to have_content('Número nota de entrega')
      expect(page).to have_content('Fecha nota de entrega')
      expect(page).to have_content('Número C-31')
      expect(page).to have_content('Fecha C-31')
      expect(Ingreso.count).to eq(1)
      expect(Ingreso.first.assets.count).to eq(3)
      expect(Ingreso.first.numero).to eq(Ingreso.count)
    end
  end
end
