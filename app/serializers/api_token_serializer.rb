class ApiTokenSerializer < ActiveModel::Serializer
  attributes :id, :email, :nombre, :token, :fecha_expiracion
end
