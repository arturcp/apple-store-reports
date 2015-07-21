require_relative 'product'

class Sale
  attr_accessor :product_id, :downloads, :updates, :revenue, :collected_date

  TABLE = '`dashboard`.`appfigures_sales`'
  COLUMNS = %w(product_id downloads updates revenue collected_date)

  def initialize(columns, values)
    hash = Hash[columns.zip(values)]
    self.product_id = hash['Apple Identifier']
    self.downloads = hash['Units']
    self.revenue = calculate_revenue(self.downloads, hash['Customer Price'])
    self.collected_date = hash['End Date']
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
    TABLE
  end

  def formatted_date
    datetime = DateTime.strptime(self.collected_date, '%m/%d/%Y')
    datetime.strftime("%Y-%m-%d")
  end

  private

  def fields
    [product_id, downloads, updates, revenue, collected_date]
  end
end