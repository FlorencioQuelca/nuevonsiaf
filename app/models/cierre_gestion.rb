class CierreGestion < ActiveRecord::Base
  belongs_to :asset
  belongs_to :gestion
end
