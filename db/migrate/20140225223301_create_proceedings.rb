class CreateProceedings < ActiveRecord::Migration
  def change
    create_table :proceedings do |t|
      t.belongs_to :user, index: true
      t.belongs_to :admin, index: true
      t.string :proceeding_type, limit: 2

      t.timestamps
    end
  end
end
