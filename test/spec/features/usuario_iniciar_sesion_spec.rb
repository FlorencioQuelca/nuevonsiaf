require 'rails_helper'

describe 'Inicio de sesión de usuarios' do
  let(:usuario) { create(:user) }

  it 'con credenciales válidos' do
    iniciar_sesion(usuario)

    expect(page).to have_content('Has iniciado sesión correctamente.')
  end


  it 'con credenciales inválidos' do
    usuario.password = 'contraseña-inválida'
    iniciar_sesion(usuario)

    click_on 'INGRESAR'

    expect(page).to have_content('Nombre de Usuario o contraseña inválidos.')
  end
end
