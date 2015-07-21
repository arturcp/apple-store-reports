#Created to be used with ruby >= 1.9
require 'benchmark'
require 'date'
require_relative 'models/colors'

def usage
  puts 'Usage:'
  puts 'VENDOR=12345678 FROM=2015-01-01 ruby database_load.rb'
  puts
  puts 'Date format: yyyy-mm-dd'
  abort
end

time = Benchmark.realtime do
  if !ENV['VENDOR'] || !ENV['FROM']
    usage
  end

  directory = ''
  directory = "DIRECTORY=#{ENV['DIRECTORY']}" if ENV['DIRECTORY']

  four_days_ago = Date.today - 4

  begin
    initial_date = Date.strptime(ENV['FROM'], '%Y-%m-%d')
  rescue
    usage
  end

  four_days_ago.downto(initial_date) do |date|
    puts "--- #{date.to_s.red} ---"
    cmd = "VENDOR=#{ENV['VENDOR']} BATCH=true #{directory} YEAR=#{date.year} MONTH=#{date.month} DAY=#{date.day} ruby importer.rb"
    system(cmd)
  end
end

puts
puts 'Done.'
puts "Time elapsed #{time} seconds"