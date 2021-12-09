require 'rails_helper'

describe 'Activos fijos códigos de barras', js: true do
  let(:usuario_activos) { create(:user_activos) }
  let!(:activo1)  { create :asset, user: usuario_activos, ingreso: nil }
  let!(:activo2)  { create :asset, user: usuario_activos, ingreso: nil }
  let!(:activo3)  { create :asset, user: usuario_activos, ingreso: nil }
  let!(:activo4)  { create :asset, user: usuario_activos, ingreso: nil }
  let!(:activo5)  { create :asset, user: usuario_activos, ingreso: nil }

  before { iniciar_sesion(usuario_activos) }
  after(:each, logout: true) { cerrar_sesion(usuario_activos) }

  it 'ingresar al enlace', logout: true do
    visit barcodes_path

    expect(page).to have_content('Sistema de Activos Fijos')
    expect(page).to have_content('Código de Barras')
    expect(page).to have_content('Buscar')
  end

  it 'seleccionar activos por rango', logout: true do
    visit barcodes_path

    rango = "#{activo1.code}-#{activo4.code}"

    fill_in 'code', with: rango; click_on 'Buscar'; wait_for_ajax

    expect(page).to have_content(activo1.detalle)
    expect(page).to have_content(activo2.detalle)
    expect(page).to have_content(activo3.detalle)
    expect(page).to have_content(activo4.detalle)
    expect(page).to have_no_content(activo1.description)
    expect(page).to have_no_content(activo2.description)
    expect(page).to have_no_content(activo3.description)
    expect(page).to have_no_content(activo4.description)
    expect(page).to have_no_content(activo5.detalle) 
    expect(page).to have_content('Imprimir')
    expect(page).to have_css('button.imprimir')
  end

  it 'seleccionar varias veces un activo', logout: true do
    visit barcodes_path

    rangos = []

    2.times { rangos << activo1.code }
    3.times { rangos << activo2.code }
    rangos << "#{activo3.code}-#{activo5.code}"

    fill_in 'code', with: rangos.join(','); click_on 'Buscar'; wait_for_ajax

    expect(page).to have_content(activo1.detalle, count: 2)
    expect(page).to have_content(activo2.detalle, count: 3)
    expect(page).to have_content(activo3.detalle)
    expect(page).to have_content(activo4.detalle)
    expect(page).to have_content(activo5.detalle)
  end

  it 'descargar archivo PDF', driver: :webkit do
    visit barcodes_path

    rangos = []
    rangos << activo1.code
    rangos << activo2.code
    rangos << activo3.code
    rangos << activo4.code
    rangos << activo5.code

    fill_in 'code', with: rangos.join(','); click_on 'Buscar'; wait_for_ajax

    expect(find('#preview-barcodes')).to have_selector('.thumbnail', count: 5)
    expect(page).to have_content('Imprimir')

    click_on 'Imprimir'

    sleep 1 # A la espera para la descarga

    # El acta de entrega en PDF (no implementado en selenium)
    archivo = "#{'código de barras'.parameterize}.pdf"
    expect(response_headers['Content-Type']).to eq('application/pdf')
    expect(response_headers['Content-Disposition']).to eq("attachment; filename=\"#{archivo}\"")
    expect(response_headers['Content-Transfer-Encoding']).to eq('binary')
  end
end
