class AddCodigoAntiguoToSubarticles < ActiveRecord::Migration
  def up
    add_column :subarticles, :code_old, :string
    Subarticle.update_all("code_old=code, code=null, barcode=null")
  end

  def down
    Subarticle.update_all("code=code_old, barcode=code_old")
    remove_column :subarticles, :code_old
  end
end
