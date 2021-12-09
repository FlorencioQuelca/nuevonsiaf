class WelcomeController < ApplicationController
  def index
    authorize! :index, :welcome
  end

  def datatables_spanish
    send_file(
      "#{Rails.root}/public/locales/dataTables.spanish.txt",
      filename: 'dataTables.spanish.txt',
      type: 'text/plain'
    )
  end
end
