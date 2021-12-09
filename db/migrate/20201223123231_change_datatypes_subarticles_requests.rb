class ChangeDatatypesSubarticlesRequests < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE subarticle_requests MODIFY COLUMN amount DECIMAL(10,2);
    SQL
    execute <<-SQL
      ALTER TABLE subarticle_requests MODIFY COLUMN amount_delivered DECIMAL(10,2);
    SQL
    execute <<-SQL
      ALTER TABLE subarticle_requests MODIFY COLUMN total_delivered DECIMAL(10,2);
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE subarticle_requests MODIFY COLUMN amount INT(11);
    SQL
    execute <<-SQL
      ALTER TABLE subarticle_requests MODIFY COLUMN amount_delivered INT(11);
    SQL
    execute <<-SQL
      ALTER TABLE subarticle_requests MODIFY COLUMN total_delivered INT(11);
    SQL
  end  
end
