module IniciarSesion
  def iniciar_sesion(usuario)
    visit new_user_session_path

    fill_in 'user_username', with: usuario.username
    fill_in 'user_password', with: usuario.password

    click_on 'INGRESAR'
  end

  def cerrar_sesion(usuario)
    click_link usuario.name

    click_link 'Cerrar Sesión'
  end
end

RSpec.configure do |config|
  config.include IniciarSesion, type: :feature
end
