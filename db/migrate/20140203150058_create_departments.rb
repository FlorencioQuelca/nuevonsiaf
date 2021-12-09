class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :code,   limit: 50
      t.string :name,   limit: 230
      t.string :status, limit: 2
      t.belongs_to :building, index: true

      t.timestamps
    end
  end
end
