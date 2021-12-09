require 'rails_helper'

describe 'Activos' do
  let(:usuario) { create(:user_activos) }

  it 'listado vacío', js: true do
    iniciar_sesion(usuario)

    visit assets_path

    expect(page).to have_content('Activos')
    expect(page).to have_content('Nuevo Activo')
    expect(page).to have_content('Mostrando 0 al 0 de 0 registros')
  end
end
