class UserSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :code, :name, :username, :title, :ci, :email, :entity_name, :department_name, :phone, :mobile, :role, :estado, :urls

  def estado
    object.status == "1" ? 'ACTIVO' : 'INACTIVO'
  end

  def urls
    {
      list: users_path,
      show: user_path(object),
      edit: edit_user_path(object),
      historico_almacen:  historico_almacen_user_path(object),
      historico: obt_historico_actas_api_user_path(object, format: :json),
      download_activos_pdf: download_user_path(object, format: :pdf),
      download_activos_csv: download_user_path(object, format: :csv)
    }
  end
end
