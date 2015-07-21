require 'benchmark'
require_relative 'models/colors'

def usage
  puts 'Usage:'
  puts
  puts 'ID=12345678901234567890 YEAR=2015 MONTH=7 ruby start.rb'.green
  puts
  puts 'All fields are mandatory'
  puts
end

def validate_required_fields
  if !ENV['VENDOR'] || !ENV['YEAR'] || !ENV['MONTH'] || !ENV['DAY']
    usage
    abort
  end
end

def start
  import = "VENDOR=#{ENV['VENDOR']} YEAR=#{ENV['YEAR']} MONTH=#{ENV['MONTH']} DAY=#{ENV['DAY']} ruby importer.rb"
  generate_sql = "ruby sql_generator.rb"
  restore_mysql = "ruby mysql_import.rb"

  system(import)
  system(generate_sql)
  system(restore_mysql)
end

time = Benchmark.realtime do
  validate_required_fields
  start
end

puts ''
puts 'Done.'
puts "Time elapsed #{time} seconds"