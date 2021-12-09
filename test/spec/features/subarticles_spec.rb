require 'rails_helper'

describe 'Subartículos' do
  let(:usuario) { create(:user_almacenes) }

  it 'listado vacío', js: true do
    iniciar_sesion(usuario)

    visit subarticles_path

    expect(page).to have_content('Subartículos de Materiales')
    expect(page).to have_content('Nuevo Subartículo')
    expect(page).to have_content('Mostrando 0 al 0 de 0 registros')
  end
end
