#Created to be used with ruby >= 1.9
require 'fileutils'
require 'benchmark'
require_relative 'colors'

DEFAULT_DIRECTORY = './ios_reports'
CONFIG_FILE = 'report.properties'

REPORTS = ['installs', 'ratings', 'crashes']

def welcome_message
  puts "+-+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+"
  puts "|A|p|p|l|e| |S|t|o|r|e| |I|m|p|o|r|t|e|r|"
  puts "+-+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+"
  puts
end

def required_fields_message
  if ENV['VENDOR'].nil?
    puts "#{"The vendor id is required".red}"
    puts
    puts 'Usage:'
    puts "#{"VENDOR=12345678".green} YEAR=2015 MONTH=7 DAY=3 ruby importer.rb"
    puts
    puts 'YEAR, MONTH and DAY are optional parameters'
    abort
  end
end

def properties_message
  unless File.exist?(CONFIG_FILE)
    puts "#{"Error".red}: #{CONFIG_FILE} not found. Rename the file report.properties.sample and change its contents before running the importer"
    abort
  end
end

def gz_file_message
  unless Dir.glob('*.txt.gz').empty?
    puts "#{"Attention".yellow}: it seems the importer is already running. "
    puts "If you are sure it is not the case, we will remove all .txt.gz files and move on. Do you want to continue? #{"(y/n)".light_blue}"
    answer = gets.downcase[0]

    if answer == 'y'
      puts File.delete(*Dir.glob('*.txt.gz'))
      puts
    else
      abort
    end
  end
end

def directory_message
  unless ENV['DIRECTORY']
    puts '** IMPORTANT **'.yellow
    puts "No directory was provided. The reports will be stored in #{DEFAULT_DIRECTORY.light_blue}"
    puts
  end
end

def assert_directory_exists(directory)
  unless File.directory?(directory)
    puts "#{"[Warning]".gray}: #{directory} did not exist and was created"
    FileUtils::mkdir_p(directory)
  end
end

def java_command
  year = ENV['YEAR'] || Time.now.year.to_s
  month = ENV['MONTH'] || Time.now.month.to_s
  day = ENV['DAY'] || (Time.now.day - 1).to_s

  id = ENV['ID']

  date = "#{year}#{month.rjust(2, '0')}#{day.rjust(2, '0')}"
  puts "Running importer for date #{date}"

  "java Autoingestion report.properties #{ENV['VENDOR']} Sales Daily Sumary #{date}"
end

def fetch_from_apple_store
  system(java_command)
end

def copy_zip_to_folder(directory)
  system("cp *.txt.gz #{directory} | rm -f *.txt.gz")
end

def unzip_file(directory)
  system("gunzip #{directory}/*.gz")
end

def import_files(directory)
  puts '*********** Starting Import ***********'

  assert_directory_exists(directory)
  fetch_from_apple_store
  copy_zip_to_folder(directory)
  unzip_file(directory)

  puts
  puts '***************************************'
end

def messages
  welcome_message
  properties_message
  required_fields_message
  gz_file_message
  directory_message
end

def start
  directory = ENV['DIRECTORY'] || DEFAULT_DIRECTORY
  import_files(directory)
end

time = Benchmark.realtime do
  start
end

puts
puts 'Done.'
puts "Time elapsed #{time} seconds"
