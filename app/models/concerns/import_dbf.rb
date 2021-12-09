module ImportDbf
  extend ActiveSupport::Concern

  CORRELATIONS = Hash.new

  included do
    unless self.const_defined?(:CORRELATIONS)
      self.const_set :CORRELATIONS, ImportDbf::CORRELATIONS
    end
  end

  module ClassMethods
    ##
    # Importar el archivo DBF a la tabla de usuarios
    def import_dbf(dbf)
      url_base = Rails.application.secrets.convert_api_url
      url_api = 'dbf/json' # DBF => JSON
      site = RestClient::Resource.new url_base, verify_ssl: false
      file = File.new(dbf.tempfile, 'rb')
      users = JSON.parse(site[url_api].post(filedata: file))
      users = Asset.ordenar_fecha_factura(users) if self.name == 'Asset'
      i = j = n = 0
      transaction do
        users.each_with_index do |record, index|
          print "#{index + 1}.-\t"
          if record.present? && record['deleted'] == 0
            self.const_get(:CORRELATIONS).each { |k, v| print "#{record[k].inspect}, " }
            save_correlations(record) ? i += 1 : n += 1
          else
            j += 1
            print record.inspect
          end
          puts ''
        end
        # Obtiene las UFVs necesarias y las gestiones de los activos actuales.
        Asset.completa_migracion if self.name == 'Asset'
      end
      [i, n, j] # insertados, no insertados, nils
    end

    private

    ##
    # Guarda en la base de datos de acuerdo a la correspondencia de campos.
    def save_correlations(record)
      import_data = Hash.new
      self.const_get(:CORRELATIONS).each do |origin, destination|
        import_data.merge!({ destination => record[origin] })
      end
      import_data.present? && self.new(import_data).save
    end
  end
end
