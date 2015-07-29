require 'benchmark'
require 'fileutils'
require 'json'

require_relative 'models/colors'
require_relative 'models/product'
require_relative 'models/sale'

DEFAULT_DIRECTORY = './reports'
INSERT_IGNORE = 'INSERT IGNORE INTO %{table_name} (%{columns}) VALUES (%{values});'
INSERT = 'INSERT INTO %{table_name} (%{columns}) VALUES (%{values});'
OUTPUT_FILE_NAME = Time.now.strftime('%Y%m%d%H%M%S%L')

def welcome_message
  puts '+-+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+'
  puts '|A|p|p|l|e| |S|t|o|r|e| |I|m|p|o|r|t|e|r|'
  puts '+-+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+'
  puts
end

def sql_message
  puts '** Important **'.yellow
  puts ''
  puts "The script will generate a .sql file with the insert commands to generate the database. The file will be available at #{"./sql".light_blue}"
  puts ''
end

def directory_message
  unless ENV['DIRECTORY']
    puts "* No directory was provided. The reports will be stored in #{DEFAULT_DIRECTORY.light_blue}"
  end
  puts ''
end

def write_to_log(error)
  directory = './logs'
  filename = "#{directory}/#{OUTPUT_FILE_NAME}.log"

  unless File.directory?(directory)
    FileUtils::mkdir_p(directory)
  end

  file_mode = File.exists?(filename) ? 'a+' : 'w+'
  File.open(filename, file_mode) { |file| file.write("#{error}\n") }
end

def write_to_file(inserts)
  directory = './sql'
  filename = "#{directory}/#{OUTPUT_FILE_NAME}.sql"

  unless File.directory?(directory)
    puts "#{"[Warning]".gray}: #{directory} did not exist and was created"
    FileUtils::mkdir_p(directory)
  end

  file_mode = File.exists?(filename) ? 'a' : 'w'
  open(filename, "#{file_mode}:UTF-8") { |file| file.write(inserts.join("\n")) }
end

def load_generated_icons
  path = 'generated_icons.json'
  if File.exists?(path)
    file = File.open(path, "rb:UTF-8")
    Product.icons = JSON.parse(file.read)
  end
end

def save_generated_icons
  open('generated_icons.json', "w:UTF-8") { |file| file.write(Product.icons.to_json) }
end

def import_products(imported_file_name, columns, lines)
  load_generated_icons
  inserts = ["-- PRODUCTS REPORT: #{imported_file_name}"]

  lines.each do |line|
    item = {}
    values = line.split("\t")

    product = Product.new(columns, values)

    if values.length > 1
      inserts << INSERT_IGNORE % { table_name: Product.table, columns: product.columns, values: product.values }
    end
  end

  inserts << " \n "
  write_to_file(inserts)
  save_generated_icons
end

def import_sales(imported_file_name, columns, lines)
  inserts = ["-- SALES REPORT"]

  lines.each do |line|
    item = {}
    values = line.split("\t")

    sale = Sale.new(columns, values)

    if values.length > 1 && sale.app_download?
      inserts << INSERT % { table_name: Sale.table, columns: sale.columns, values: sale.values }
    end
  end

  inserts << " \n "
  write_to_file(inserts)
end

def update_field_sum(field)
  sql = "UPDATE #{Product.table} p " +
        "INNER JOIN (" +
        "  SELECT product_id, SUM(#{field}) as #{field}" +
        "  FROM #{Sale.table}" +
        "  GROUP BY product_id" +
        ") s ON s.product_id = p.id" +
        " SET p.#{field} = s.#{field} " +
        " WHERE p.store = 'APPLE'; "
end

def calculate_related_fields
  inserts = ["-- RELATED VALUES"]

  inserts << update_field_sum('downloads')
  inserts << update_field_sum('revenue')
  inserts << update_field_sum('updates')
  inserts << " \n "
  write_to_file(inserts)
end

def import_data(file)
    imported_file_name = file.split('/').last
    lines = File.open(file, "rb:UTF-8") { |f| f.readlines }
    columns = lines.shift.split("\t")

    import_products(imported_file_name, columns, lines)
    import_sales(imported_file_name, columns, lines)

    dots = '.' * (120 - imported_file_name.length).abs
    puts "* #{imported_file_name.light_blue} #{dots} #{"done".green}"
    File.delete(file)
  rescue => e
    puts "* #{imported_file_name.light_blue} #{dots} #{"error".red}"
    write_to_log("#{e} \n #{e.backtrace}")
end

def start
  welcome_message
  directory_message
  sql_message

  puts 'Starting SQL generation...'
  puts '=========================='
  puts ''

  directory = ENV['DIRECTORY'] || DEFAULT_DIRECTORY
  files = Dir.glob("#{directory}/*.txt")
  files.each do |csv|
    import_data(csv)
  end

  calculate_related_fields if files.length > 0
end

time = Benchmark.realtime do
  start
end

puts ''
puts 'Done.'
puts "Time elapsed #{time} seconds"