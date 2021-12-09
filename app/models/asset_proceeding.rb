class AssetProceeding < ActiveRecord::Base
  belongs_to :proceeding
  belongs_to :asset
end
