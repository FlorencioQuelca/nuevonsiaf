class CreateDeclines < ActiveRecord::Migration
  def change
    create_table :declines do |t|
      t.string :asset_code, limit: 50
      t.string :account_code, limit: 50
      t.string :auxiliary_code, limit: 50
      t.string :department_code, limit: 50
      t.string :user_code, limit: 50
      t.text :description
      t.text :reason
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
