class Sale
  COLUMNS = %w(product_id downloads updates revenue collected_date)

  def initialize(columns, values)
    hash = Hash[columns.zip(values)]
    self.product_id = hash['Apple Identifier']
  end

  def columns
    COLUMNS.map { |column| "`#{column}`" }.join(', ')
  end

  def values
    fields.map { |value| "'#{value}'" }.join(', ')
  end

  private

  def fields
    [product_id, downloads, updates, revenue, collected_date]
  end
end