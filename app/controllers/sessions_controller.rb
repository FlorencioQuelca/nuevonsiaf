class SessionsController < Devise::SessionsController
  after_action :session_log, only: [:create]
  before_action :session_log, only: [:destroy]

  layout 'login'

  private

  def session_log
    action = action_name == 'destroy' ? 'logout' : 'login'
    current_user.register_log(action) if user_signed_in?
  end
end
