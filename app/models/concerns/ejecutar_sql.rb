module EjecutarSQL
  extend ActiveSupport::Concern

  def ejecutar_sql(sql)
    # Cambiado según recomendación de https://stackoverflow.com/a/29809938/1174245
    # y http://api.rubyonrails.org/v5.2/classes/ActiveRecord/ConnectionAdapters/ConnectionPool.html
    self.class.connection_pool.with_connection do |conn|
      conn.exec_query(sql)
    end
  end

  module ClassMethods
    def ejecutar_sql(sql)
      self.new.ejecutar_sql(sql)
    end
  end
end
