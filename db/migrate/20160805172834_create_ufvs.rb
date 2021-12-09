class CreateUfvs < ActiveRecord::Migration
  def change
    create_table :ufvs do |t|
      t.date :fecha
      t.decimal :valor, null: false, default: 0
      t.decimal :valor, precision: 7, scale: 5, null: false, default: 0

      t.timestamps null: false
    end
  end
end
