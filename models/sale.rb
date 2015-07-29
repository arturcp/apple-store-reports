require_relative 'product'
require_relative 'db_config'

class Sale
  attr_accessor :product_id, :downloads, :updates, :revenue, :collected_date, :product_type_identifier

  TABLE = '`%{database}`.`appfigures_sales`'
  COLUMNS = %w(product_id downloads updates revenue collected_date)

  def initialize(columns, values)
    hash = Hash[columns.zip(values)]
    self.product_id = hash['Apple Identifier']
    self.downloads = hash['Units']
    self.revenue = calculate_revenue(self.downloads, hash['Customer Price'])
    self.collected_date = hash['End Date']
    self.product_type_identifier = hash['Product Type Identifier']
  end

  def columns
    COLUMNS.map { |column| "#{column}" }.join(', ')
  end

  def values
    "#{product_query}, #{downloads}, 0, '#{revenue}', '#{formatted_date}'"
  end

  def product_query
    "(select id from #{Product.table} where product_id = '#{self.product_id}' limit 1)"
  end

  def calculate_revenue(downloads, price)
    downloads = downloads.to_i || 0
    price = price.to_f || 0
    downloads * price
  end

  def self.table
    @table ||= begin
      TABLE % { database: DBConfig.database }
    end
  end

  def formatted_date
    datetime = DateTime.strptime(self.collected_date, '%m/%d/%Y')
    datetime.strftime("%Y-%m-%d")
  end

  def app_download?
    product_type_identifier && self.product_type_identifier[0] == '1'
  end

  private

  def fields
    [product_id, downloads, updates, revenue, collected_date]
  end
end