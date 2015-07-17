Download statistics reports from Apple Store using ruby scripts.


Requirements
================

ruby >= 1.9


Before starting
================

The script uses the AutoIngestion.class file provided by Apple on his instructions manual: http://www.apple.com/itunesnews/docs/AppStoreReportingInstructions.pdf. The pdf is included in the project folder.

Make sure you can run java before using this project.


The project
================

There are two important ruby scripts in this project:

1. importer.rb

This script is responsible to fetch and download a report from Apple Store containing the statistics of your apps. Before running it, make sure you know what is your Vender Id. You can find it on https://reportingitc2.apple.com/reports.html. On the examples, we will use the vendor id 12345678.

Now, on the terminal, execute:

`VENDOR=12345678 ruby importer.rb`

By default, a folder named "reports" will be created and the data downloaded from Apple Store will be stored in it. It is possible to change the default directory by setting the ENV['DIRECTORY'] on the script call. For example:

`DIRECTORY=./new_folder VENDOR=12345678 ruby importer.rb`

It is possible to specify the year, month and day to import data. To do that, make use of the parameters DAY, MONTH and YEAR:

`VENDOR=12345678 YEAR=2015 MONTH=7 DAY=3 ruby importer.rb`

If no year, month and day values are provided, the importer will use information from yesterday (considering today the date where the script is being run)


2. sql_generator.rb

This script will read all the files in the given directory and generate a set of insert commands to be run on a database. Just like in the import.rb file, you can override the default folder with the ENV['DIRECTORY'] parameter.

To execute it, go to the terminal and run:

`ruby sql_generator.rb`

You can use a different folder (it must match the one used on import.rb):

`DIRECTORY=./new_folder ruby sql_generator.rb`
