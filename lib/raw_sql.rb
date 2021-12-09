# Extractado desde el sitio:
# http://gmile.me/raw-sql-in-a-rails-project/
class RawSQL
  include ActiveRecord::ConnectionAdapters::Quoting

  def initialize(filename)
    @filename = filename
  end

  def result(params = {})
    ActiveRecord::Base.connection.exec_query(query % quoted_parameters(params))
  end

  private

  attr_reader :filename

  def query
    Rails.root.join('lib', 'sql', filename).read
  end

  def quoted_parameters(params)
    params.each_with_object({}) do |(key, value), result|
      result[key] =
      if value.is_a?(Array)
        value.map { |item| quote(item) }.join(', ')
      elsif value.is_a?(Integer)
        value
      else
        quote(value)
      end
    end
  end
end
