Download statistics reports from Apple Store using ruby scripts.

If you need a tool to download data from the Google Play Store, check the project at https://github.com/arturbcc/google-store-reports


Requirements
================

ruby >= 1.9


Before starting
================

The script uses the AutoIngestion.class file provided by Apple on his instructions manual: http://www.apple.com/itunesnews/docs/AppStoreReportingInstructions.pdf. The pdf is included in the project's `doc` folder.

Make sure you can run java before using this project.


Easy Run
================

To make a long story short:

- To fetch data from a specific date and import them into the database, run:
`VENDOR=12345678 YEAR=2015 MONTH=7 DAY=3 ruby start.rb`

- Instead of picking a date, you can load the database with all data provided by Apple by running:
`VENDOR=12345678 FROM=2015-01-01 ruby database_load.rb`

Now, to understand how things work and what other options you have, just read on.



The project
================

There are four important ruby scripts in this project:

1. importer.rb

This script is responsible to fetch and download a report from Apple Store containing the statistics of your apps. Before running it, make sure you know what is your Vender Id. You can find it on https://reportingitc2.apple.com/reports.html. On the examples, we will use the vendor id 12345678.

Now, on the terminal, execute:

`VENDOR=12345678 ruby importer.rb`

By default, a folder named "reports" will be created and the data downloaded from Apple Store will be stored in it. It is possible to change the default directory by setting the ENV['DIRECTORY'] on the script call. For example:

`DIRECTORY=./new_folder VENDOR=12345678 ruby importer.rb`

It is possible to specify the year, month and day to import data. To do that, make use of the parameters DAY, MONTH and YEAR:

`VENDOR=12345678 YEAR=2015 MONTH=7 DAY=3 ruby importer.rb`

If no year, month and day values are provided, the importer will use information from 4 days ago (considering `today` the date when the script is being run)


2. sql_generator.rb

This script will read all the files in the given directory and generate a set of insert commands to be run on a database. Just like in the importer.rb file, you can override the default folder with the ENV['DIRECTORY'] parameter.

To execute it, go to the terminal and run:

`ruby sql_generator.rb`

You can use a different folder (it must match the one used on importer.rb):

`DIRECTORY=./new_folder ruby sql_generator.rb`


3. mysql_import.rb

After the csv files are converted to sql scripts, you can easily import them to your database by running the mysql_import script:

`ruby mysql_import.rb`

To make it work, you need to configure your database connection. There is a file on the `config` folder called 'config.json.sample'. Rename it to config.json and change the username, password and database information with your database information before you run the script, or a error message will be shown explaining about this json file.


4. start.rb

To make it easier to run all scripts, you can easily run the whole process with one single command, ignoring the previous scripts mentioned above. It is good to understand how each of them work to debug eventual problems that might arise, but once everything is settled you can just go to the terminal and run:

`VENDOR=12345678 YEAR=2015 MONTH=7 DAY=3 ruby start.rb`

It will call the following commands on the given sequence:

* VENDOR=12345678 YEAR=2015 MONTH=7 DAY=3 ruby importer.rb
* ruby sql_generator.rb
* ruby mysql_import.rb


Database structure
==========================

To create the database, we included a mysql script on the project. It is database_script.sql and is located on the `db` folder.


Database first load
==========================

To load the initial content into your database, you can use the database_load.rb script. You must inform the vendor, just like you do to import a specific date, and must provide the initial date. The script will download all files from the given date up to four days ago. Then you can run the sql generator script normally.

Just go to the terminal and run:

`VENDOR=12345678 FROM=2015-01-01 ruby database_load.rb`