require 'rails_helper'

describe 'Activos fijos', js: true do
  def seleccionar_activos_fijos(activo1, activo2)
    fill_in 'code', with: activo1.code; click_on 'Enviar'; wait_for_ajax
    fill_in 'code', with: activo2.code; click_on 'Enviar'; wait_for_ajax

    click_on 'Siguiente'
  end

  context 'Devolución:' do
    let(:institucion)      { create(:entity) }
    let(:entidad)          { create(:building, entity: institucion) }
    let(:unidad)           { create(:department, building: entidad) }
    let!(:usuario_activos) { create(:user_activos, department: unidad) }
    let!(:usuario1)        { create(:user, department: unidad) }
    let!(:usuario2)        { create(:user, department: unidad) }
    let!(:activo1)         { create(:asset, user: usuario1, ingreso: nil) }
    let!(:activo2)         { create(:asset, user: usuario2, ingreso: nil) }
    let!(:activo3)         { create(:asset, user: usuario1, ingreso: nil) }
    let!(:activo4)         { create(:asset, user: usuario1, ingreso: nil) }
    let!(:activo5)         { create(:asset, user: usuario_activos, ingreso: nil) }

    before { iniciar_sesion(usuario_activos) }
    after(:each, logout: true) { cerrar_sesion(usuario_activos) }

    it 'cantidades en los modelos' do
      expect(usuario1.assets.count).to eq(3)
      expect(usuario2.assets.count).to eq(1)
      expect(usuario_activos.assets.count).to eq(1)
    end

    it 'enlace para devolución', logout: true do
      visit assignation_assets_path

      first('#dropdownMenu').click
      click_on 'Devolución'

      expect(page).to have_content('Devolución de Activos Fijos')
    end

    it 'selección de activos fijos que no correponden al funcionario', logout: true do
      visit devolution_assets_path

      fill_in 'code', with: activo1.code; click_on 'Enviar'; wait_for_ajax
      fill_in 'code', with: activo2.code; click_on 'Enviar'; wait_for_ajax

      expect(page).to have_content("El Activo con código #{activo2.code} pertenece a otro funcionario:")
      expect(page).to have_content(usuario2.name)
      expect(page).to have_content(usuario2.title)
    end

    it 'selección de activos fijos y previsualización de acta', logout: true do
      visit devolution_assets_path

      seleccionar_activos_fijos(activo1, activo3)

      expect(page).to have_content('ACTA DE DEVOLUCIÓN DE BIENES')
      expect(page).to have_content(usuario1.name)
      expect(page).to have_content(usuario1.title)
      expect(page).to have_content(usuario1.ci)
      expect(page).to have_content(activo1.description)
      expect(page).to have_content(activo3.description)
      expect(page).to have_content('DEVOLUCIÓN DE ACTIVOS')
    end

    it 'guardar y descargar acta' do
      visit devolution_assets_path

      seleccionar_activos_fijos(activo1, activo3)

      click_on 'Imprimir PDF'

      sleep 1 # A la espera para la descarga

      if Capybara.javascript_driver == :webkit
        # El acta de entrega en PDF (no implementado en selenium)
        archivo = "#{usuario1.name.parameterize || 'acta'}.pdf"
        expect(response_headers['Content-Type']).to eq('application/pdf')
        expect(response_headers['Content-Disposition']).to eq("attachment; filename=\"#{archivo}\"")
        expect(response_headers['Content-Transfer-Encoding']).to eq('binary')
      end

      # Cantidades que debe haber
      expect(usuario1.proceedings.count).to eq(1)
      expect(usuario1.assets.count).to eq(1)
      expect(usuario2.assets.count).to eq(1)
      expect(usuario_activos.assets.count).to eq(3)
      expect(Proceeding.count).to eq(1)
    end
  end
end
