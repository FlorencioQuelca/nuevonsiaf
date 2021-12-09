class DashboardController < ApplicationController
  def index
    @user = current_user
  end

  def update_password
    @user = User.find(current_user.id)
    if @user.change_password(user_params)
      sign_in @user, bypass: true
      redirect_to dashboard_url, notice: 'Su contraseña se actualizó correctamente'
    else
      render "index"
    end
  end

  ##
  # Ocultar la alerta de cambiar contraseña para cada usuario
  def hide
    @user = User.find(current_user.id)
    @user.hide_announcement
    render nothing: true
  end

  private

  def user_params
    params.required(:user).permit(:current_password, :password, :password_confirmation)
  end
end
