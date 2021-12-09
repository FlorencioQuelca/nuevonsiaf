class CreateAuxiliaries < ActiveRecord::Migration
  def change
    create_table :auxiliaries do |t|
      t.string :code, limit: 50
      t.string :name, limit: 230
      t.belongs_to :account, index: true

      t.timestamps
    end
  end
end
