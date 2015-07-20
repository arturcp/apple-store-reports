#Created to be used with ruby >= 1.9
require 'fileutils'
require 'benchmark'
require 'date'
require_relative 'colors'

DEFAULT_DIRECTORY = './reports'
CONFIG_FILE = 'report.properties'

REPORTS = ['installs', 'ratings', 'crashes']

def welcome_message
  puts "+-+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+"
  puts "|A|p|p|l|e| |S|t|o|r|e| |I|m|p|o|r|t|e|r|"
  puts "+-+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+"
  puts
end

def required_fields_message
  unless ENV['VENDOR']
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

def existing_file_message(directory)
  path = "#{directory}/*.*"
  unless Dir.glob(path).empty?
    puts "#{"Attention".yellow}: it seems the importer is already running. There are files on the reports folder. "
    puts "If you are sure it is not the case, we will remove all the files from #{directory.light_blue} and move on. Do you want to continue? #{"(y or n)?".light_blue}"
    answer = gets.downcase[0]

    if answer == 'y'
      puts "#{File.delete(*Dir.glob(path))} file(s) removed"
      puts
    else
      puts 'aborted'
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
  today = Date.today - 4
  year = ENV['YEAR'] || today.year.to_s
  month = ENV['MONTH'] || today.month.to_s
  day = ENV['DAY'] || today.day.to_s

  id = ENV['ID']

  date = "#{year}#{month.rjust(2, '0')}#{day.rjust(2, '0')}"
  puts "Running importer for date #{date}"

  "java Autoingestion report.properties #{ENV['VENDOR']} Sales Daily Sumary #{date}"
end

def fetch_from_apple_store
  system(java_command)
end

def copy_zip_to_folder(directory)
  system("mv *.txt.gz #{directory}")
end

def unzip_file(directory)
  system("gunzip #{directory}/*.gz")
end

def import_files(directory)
  existing_file_message(directory)
  puts '*********** Starting Import ***********'
  puts

  assert_directory_exists(directory)
  fetch_from_apple_store
  copy_zip_to_folder(directory)
  unzip_file(directory)

  puts
  puts "To generate the sql, run #{"ruby sql_generator.rb".green}"
  puts
  puts '***************************************'
end

def messages
  welcome_message
  properties_message
  required_fields_message
  directory_message
end

def start
  messages
  import_files(ENV['DIRECTORY'] || DEFAULT_DIRECTORY)
end

time = Benchmark.realtime do
  start
end

puts
puts 'Done.'
puts "Time elapsed #{time} seconds"