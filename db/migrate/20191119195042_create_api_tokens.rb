class CreateApiTokens < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
      t.string :email, null: false, unique: true
      t.string :nombre, null: false
      t.text :token, null: false
      t.date :fecha_expiracion
      t.string :status, limit: 2

      t.timestamps null: false
    end
  end
end
