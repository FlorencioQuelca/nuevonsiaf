class AdminAssetSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :description, :code, :user, :auxiliary, :state

  has_one :user, serializer: UserSerializer

  def auxiliary
    object.auxiliary_name
  end

  def state
    object.get_state
  end
end
