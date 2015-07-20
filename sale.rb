class Sale
  attr_accessor :product_id, :downloads, :updates, :revenue, :collected_date

  COLUMNS = %w(product_id downloads updates revenue collected_date)

  def initialize(columns, values)
    hash = Hash[columns.zip(values)]
    self.product_id = hash['Apple Identifier']
    self.downloads = hash['Units']
    self.revenue = calculate_revenue(self.downloads, hash['Customer Price'])
    self.collected_date = hash['End Date']
  end

  def columns
    COLUMNS.map { |column| "`#{column}`" }.join(', ')
  end

  def values
    fields.map { |value| "'#{value}'" }.join(', ')
  end

  def calculate_revenue(downloads, price)
    downloads = downloads.to_i || 0
    price = price.to_f || 0
    downloads * price
  end

  private

  def fields
    [product_id, downloads, updates, revenue, collected_date]
  end
end