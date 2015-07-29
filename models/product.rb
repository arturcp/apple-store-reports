require_relative 'icon'
require_relative 'db_config'

class Product
  attr_accessor :product_id, :name, :icon_path, :sku,
    :package_name, :store, :release_date, :last_update,
    :last_version, :app_type, :downloads, :updates, :revenue,
    :active, :id_trademark, :apikey_flurry, :apikey_flurry2, :observation

    TABLE = '`%{database}`.`appfigures_products`'
    COLUMNS = %w(product_id name icon_path sku package_name store release_date last_update last_version app_type downloads updates revenue active id_trademark apikey_flurry apikey_flurry2 observation)

    @@icons = {}

    def initialize(columns, values)
      hash = Hash[columns.zip(values)]
      self.product_id = hash['Apple Identifier']
      self.name = hash['Title'].gsub('\'','')
      self.sku = hash['SKU']
      self.package_name = ''
      self.store = hash['Provider']

      self.release_date = nil
      self.last_update = nil
      self.last_version = hash['Version']
      self.app_type = types[hash['Product Type Identifier']]
      self.downloads = 0
      self.updates = 0
      self.revenue = nil
      self.id_trademark = 0
      self.apikey_flurry = ''
      self.apikey_flurry2 = ''
      self.observation = ''

      self.icon_path = fetch_icon(title_parameterize, self.product_id)
      self.active = active?
    end

    def self.table
      @table ||= begin
        TABLE % { database: DBConfig.database }
      end
    end

    def columns
      COLUMNS.map { |column| "#{column}" }.join(', ')
    end

    def values
      fields.map do |value|
        if ['true', 'false'].include?(value.to_s)
          value
        else
          "'#{value}'"
        end
      end.join(', ')
    end

    def active?
      !self.icon_path.nil? && !self.icon_path.empty?
    end

    def fetch_icon(title, product_id)
      unless @@icons.has_key?(product_id)
        @@icons[product_id.to_s] = Icon.fetch(title, product_id)
      end

      @@icons[product_id.to_s]
    end

    def self.icons
      @@icons
    end

    def self.icons=(value)
      @@icons = value
    end

    private

    def fields
      [
        product_id, name, icon_path, sku, package_name, store, release_date, last_update,
        last_version, app_type, downloads, updates, revenue, active, id_trademark,
        apikey_flurry, apikey_flurry2, observation
      ]
    end

    def types
      @types ||= {
        '1'     => 'Free or paid app iPhone and iPod touch (iOS)',
        '7'     => 'Update iPhone and iPod touch (iOS)',
        '1-B'   => 'App Bundle',
        '1E'    => 'Paid app Custom iPhone and iPod touch (iOS)',
        '1EP'   => 'Paid app Custom iPad (iOS)',
        '1EU'   => 'Paid app Custom universal (iOS)',
        '1F'    => 'Free or paid app Universal (iOS)',
        '1T'    => 'Free or paid app iPad (iOS)',
        '7F'    => 'Update Universal (iOS)',
        '7T'    => 'Update iPad (iOS)',
        'F1'    => 'Free or paid app Mac app',
        'F7'    => 'Update Mac app',
        'FI1'   => 'In-App Purchase Mac app',
        'IA1'   => 'In-App Purchase Purchase (iOS)',
        'IA1-M' => 'In-App Purchase Purchase (Mac)',
        'IA9'   => 'In-App Purchase Subscription (iOS)',
        'IA9-M' => 'In-App Purchase Subscription (Mac)',
        'IAC'   => 'In-App Purchase Free subscription (iOS)',
        'IAC-M' => 'In-App Purchase Free subscription (Mac)',
        'IAY'   => 'In-App Purchase Auto-renewable subscription (iOS)',
        'IAY-M' => 'In-App Purchase Auto-renewable subscription (Mac)'
      }
    end

    def title_parameterize
      self.name.downcase.strip
        .gsub(' ', '_')
        .gsub('/', '-')
        .gsub(/[àáâãäåÀÁÂÃ]/,'a')
        .gsub(/[èéêÈÉÊ]/,'e')
        .gsub(/[ìíîÌÍÎ]/,'i')
        .gsub(/[òóôõÒÓÔ]/,'o')
        .gsub(/[ùúûÙÚÛ]/,'u')
        .gsub(/[çÇ]/,'c')
        .gsub('/!?,()/', '')
    end
end