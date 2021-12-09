require 'rails_helper'

describe 'Subartículos' do
  let(:usuario) { create(:user_almacenes) }
  let!(:material) { create(:material, :papel) }
  codigo_anterior = Faker::Number.number(5)
  descripcion = 'PAPEL BOND TAMAÑO CARTA 75 GR. COLOR BLANCO'
  unidad = 'Paquete (500 hojas)'
  minimo = 10
  cantidad_inicial = 200
  costo_unitario = 1.80

  before { iniciar_sesion(usuario) }
  after  { cerrar_sesion(usuario) }

  it 'nuevo material', js: true do
    visit materials_path
    expect(page).to have_content('Nuevo Material')
    expect(page).to have_content('Mostrando 1 al 1 de 1 registros')
    expect(page).to have_content('Papel')
    expect(page).to have_content('ACTIVO')
  end

  it 'listado subarticulo vacio', js: true do
    visit subarticles_path
    expect(page).to have_content('Nuevo Subartículo')
    expect(page).to have_content('Mostrando 0 al 0 de 0 registros')
  end

  it 'Ingresando nuevo subarticulo', js: true do
    visit new_subarticle_path
    expect(page).to have_content('Nuevo Subartículo')
    expect(page).to have_content('* Grupo contable')
    expect(page).to have_content('Código anterior')
    expect(page).to have_content('* Descripción')
    expect(page).to have_content('Stock mínimo')
    select(material.description, from: 'subarticle[material_id]'); wait_for_ajax
    fill_in 'subarticle[code_old]', with: codigo_anterior
    fill_in 'subarticle[description]', with: descripcion
    fill_in 'subarticle[unit]', with: unidad
    fill_in 'subarticle[minimum]', with: minimo
    click_on 'Guardar'; wait_for_ajax
    expect(page).to have_content(codigo_anterior)
    expect(page).to have_content(descripcion)
    expect(page).to have_content(unidad)
    expect(page).to have_content('ACTIVO')
    find(:css, '.btn-success.btn-xs').click

    fill_in 'amount_0', with: cantidad_inicial
    fill_in 'unit_cost_0', with: costo_unitario
    click_on 'Guardar'
    visit subarticles_path
    expect(page).to have_content(cantidad_inicial)
  end
end
