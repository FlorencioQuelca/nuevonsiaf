class VersionsController < ApplicationController
  load_and_authorize_resource

  def index
    format_to('versions', VersionsDatatable)
  end

  def export
    ids = params[:ids]
    Version.active_false(ids) if ids.present?
    redirect_to versions_path
  end
end
