class ProceedingSerializer < ActiveModel::Serializer
  attributes :id, :obt_fecha, :tipo_acta
  has_many :assets, serializer: AssetSerializer

  def obt_fecha
    I18n.l(object.fecha)
  end

  def tipo_acta
    if object.proceeding_type == 'E'
      I18n.t('proceedings.type.assignation')
    elsif object.proceeding_type == 'D'
      I18n.t('proceedings.type.devolution')
    end
  end
end
