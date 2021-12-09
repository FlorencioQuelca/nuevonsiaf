class AddUserToGestion < ActiveRecord::Migration
  def change
    add_reference :gestiones, :user, index: true, foreign_key: true
  end
end
