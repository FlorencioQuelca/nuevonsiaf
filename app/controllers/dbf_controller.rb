class DbfController < ApplicationController
  load_and_authorize_resource class: false
  before_action only: [:index, :import]
  include NavigationHelper

  # GET /dbf/:model
  def index
    authorize! :index, :dbf
  end

  ##
  # POST /dbf/:model/import
  # Importa los datos del archivo DBF dentro de la tabla usuarios.
  def import
    authorize! :import, :dbf
    if check_dbf_file(params[:dbf])
      klass = params[:model].classify.safe_constantize

      klass.paper_trail.disable
      inserted, no_inserted, nils = klass.import_dbf(params[:dbf])
      klass.paper_trail.enable
      klass.register_log('migrated') if inserted > 0

      redirect_to :back, notice: t('migration.message_html', inserted: inserted, no_inserted: no_inserted)
    else
      redirect_to :back, alert: t('migration.alert_html', model: view_context.get_filename(params[:model]))
    end
  end

  private

  def check_dbf_file(dbf)
    dbf.present? && is_dbf_file?(dbf)
  end

  def is_dbf_file?(dbf)
    view_context.dbf_mime_types.include?(dbf.content_type) &&
      view_context.get_filename(params[:model]).downcase == dbf.original_filename.downcase
  end
end
