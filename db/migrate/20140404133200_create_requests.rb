class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :admin_id
      t.integer :user_id

      t.timestamps
    end
  end
end
