require 'benchmark'
require 'fileutils'

require_relative 'colors'
require_relative 'product'
require_relative 'sale'

DEFAULT_DIRECTORY = './reports'
INSERT = 'INSERT INTO %{table_name} (%{columns}) VALUES (%{values});'
OUTPUT_FILE_NAME = Time.now.strftime('%Y%m%d%H%M%S%L')

PRODUCTS_TABLE = '`dashboard`.`appfigures_products`'
SALES_TABLE = '`dashboard`.`appfigures_sales`'

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

def import_data(file)
    lines = File.open(file, "rb:UTF-8") { |f| f.readlines }
    inserts = []
    imported_file_name = file.split('/').last
    inserts << "-- #{imported_file_name}"

    columns = lines.shift.split("\t")

    lines.each do |line|
      item = {}
      values = line.split("\t")

      #product = Product.new(columns, values)
      sales = Sale.new(columns, values)

      if values.length > 1
        #inserts << INSERT % { table_name: PRODUCTS_TABLE, columns: product.columns, values: product.values }
        inserts << INSERT % { table_name: SALES_TABLE, columns: sales.columns, values: sales.values }
      end
    end
    inserts << " \n "

    write_to_file(inserts)
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
  Dir.glob("#{directory}/*.txt").each do |csv|
    import_data(csv)
  end
end

time = Benchmark.realtime do
  start
end

puts ''
puts 'Done.'
puts "Time elapsed #{time} seconds"