require 'rails_helper'

describe 'Activos fijos', js: true do
  def seleccionar_funcionario(entidad, unidad, usuario)
    select(entidad.name, from: 'building');   wait_for_ajax
    select(unidad.name,  from: 'department'); wait_for_ajax
    select(usuario.name, from: 'user');       wait_for_ajax

    first('#btn_assignation').click
  end

  def seleccionar_activos_fijos(activo1, activo2)
    fill_in 'code', with: activo1.code; click_on 'Enviar'; wait_for_ajax
    fill_in 'code', with: activo2.code; click_on 'Enviar'; wait_for_ajax

    click_on 'Siguiente'
  end

  context 'Asignación:' do
    let(:institucion)      { create(:entity) }
    let(:entidad)          { create(:building, entity: institucion) }
    let(:unidad)           { create(:department, building: entidad) }
    let!(:usuario_activos) { create(:user_activos, department: unidad) }
    let!(:usuario)         { create(:user, department: unidad) }
    let!(:activo1)         { create(:asset, user: usuario_activos, ingreso: nil) }
    let!(:activo2)         { create(:asset, user: usuario_activos, ingreso: nil) }

    before { iniciar_sesion(usuario_activos) }
    after(:each, logout: true) { cerrar_sesion(usuario_activos) }

    it 'cantidades en los modelos', logout: true do
      expect(institucion.buildings.count).to eq(1)
      expect(entidad.departments.count).to eq(1)
      expect(unidad.users.count).to eq(2)
      expect(Asset.count).to eq(2)
      expect(usuario_activos.assets.count).to eq(2)
      expect(usuario.assets.count).to eq(0)
      expect(Proceeding.count).to eq(0)
    end

    it 'formulario inicial', logout: true do
      visit assignation_assets_path

      expect(page).to have_content('Activos Fijos')
      expect(page).to have_content('Selección de Funcionario')
      expect(page).to have_content('Entidad')
      expect(page).to have_content('Unidad')
      expect(page).to have_content('Cancelar')
    end

    it 'selección de funcionario', logout: true do
      visit assignation_assets_path

      seleccionar_funcionario(entidad, unidad, usuario)

      expect(page).to have_content('Asignación de Activos Fijos')
      expect(page).to have_content('Enviar')
      expect(page).to have_content(usuario.name)
      expect(page).to have_content(usuario.title)
    end

    it 'selección de activos fijos y previsualización de acta', logout: true do
      visit assignation_assets_path

      seleccionar_funcionario(entidad, unidad, usuario)
      seleccionar_activos_fijos(activo1, activo2)

      expect(page).to have_content('ASIGNACIÓN INDIVIDUAL DE BIENES')
      expect(page).to have_content(usuario.name)
      expect(page).to have_content(usuario.title)
      expect(page).to have_content(usuario.ci)
      expect(page).to have_content(activo1.description)
      expect(page).to have_content(activo2.description)
      expect(page).to have_content('OBLIGACIONES SOBRE EL USO DE LOS ACTIVOS ASIGNADOS')
      expect(page).to have_content('Prohibiciones:')
      expect(page).to have_content('Obligaciones:')
      expect(page).to have_content('Responsable de Activos Fijos')
      expect(page).to have_content('Funcionario')
    end

    it 'guardar y descargar acta' do
      visit assignation_assets_path

      seleccionar_funcionario(entidad, unidad, usuario)
      seleccionar_activos_fijos(activo1, activo2)

      click_on 'Imprimir PDF'

      sleep 1 # A la espera para la descarga

      if Capybara.javascript_driver == :webkit
        # El acta de entrega en PDF (no implementado en selenium)
        archivo = "#{usuario.name.parameterize || 'acta'}.pdf"
        expect(response_headers['Content-Type']).to eq('application/pdf')
        expect(response_headers['Content-Disposition']).to eq("attachment; filename=\"#{archivo}\"")
        expect(response_headers['Content-Transfer-Encoding']).to eq('binary')
      end

      # Cantidades que debe haber
      expect(usuario.proceedings.count).to eq(1)
      expect(usuario.assets.count).to eq(2)
      expect(usuario_activos.assets.count).to eq(0)
      expect(Proceeding.count).to eq(1)
    end
  end
end
