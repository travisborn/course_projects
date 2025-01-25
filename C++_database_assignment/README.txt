Travis Born
4210344

CS2010 - Lab #5 - In-memory Database

README
___________________________________________________________________________________________

INCLUDED FILES:
-main.cpp, database.cpp, common.hpp
-this README
-makefile
-two example CSV text files (windows files) to use in testing the database:
dataCSV_original.txt (used as backup), dataCSV.txt (used while running the program)
___________________________________________________________________________________________

COMPILATION:
-WARNING! This program is designed to be run in a Linux shell, such as Ubuntu. Executing in any other place might yield unexpected results.
-Compile and link the main.cpp, database.cpp, and common.hpp files by typing the following command in the command prompt line with the folder containing these files as the current working directory:
 
 $ make

RUN (requires a file named dataCSV.txt to be present):
-To run the program, after typing the above command into the command prompt line enter the following command if you wish to enter characters into the dictionary with the keyboard:
 
 $ ./main

CLEAN:
-To clean the folder of the .o files created during compilation by typing the following command in the command prompt line with the folder containing these files as the current working directory:
 
 $ make clean
___________________________________________________________________________________________

DESCRIPTION:

-This program requires a file, either a windows or a unix file, to be named "dataCSV.txt".
-The "dataCSV.txt" file must have a fully filled out database with the first row as the schema, the second row as the column data type, and subsequent rows as records. All individual attributes of every row must be separated by commas. Every row must have the same number of attributes, matching the number of schema.
-Example dataCSV.txt file:

ID,FNAME,LNAME,AGE,BALANCE
I,A,A,I,F
23,Franco,Carlacci,50,23.4
12,John,Smith,45,67.8
67,Libero,Ficocelli,53,456.27

-Upon running, the program will read from the "dataCSV.txt" file and create an in-memory database.
-The database will be a list of vectors of strings.
-The database will hold information as decribed above and shown in the example.
-The database will be sorted upon creation, and when any record is added or deleted, in ascending order according to attributes in the first column, called the key attribute (ID in the example).
-Once the database is built, the program will wait for user input by the arrows, ">>>".
-The commands that can be input are shown in the display, and are as follows:

CLOSE
This command takes no fields or clause. It will write the database to a CSV (dataCSV.txt) file,
and then quit the program.

DELETE
This command takes no fieldname but has a single clause that identifies which records/rows to delete.

SELECT
This command will take one or more fieldnames and an optional clause.
If no clause is given, the command will display the values associated with the fieldnames
for ALL records/rows in the database.
If a clause is present, it will display the values for the requested fieldnames.

ADD
This command takes a list of comma,separated values followed by a clause identical to DELETE and SELECT.
The comma separated values will be added to the database using the key provided in the clause.

DATA
This command takes no fields or clause. It will display the current database as it would be written into the CSV file.

-when ADDing a new record, it must have the same number of attributes as there are schema, and if any extra commas are added erroneously it will cause the dataCSV.txt file to be overwritten improperly.
-The attribute type row is a guideline for what data types should be in which columns, except the key (first) attribute MUST be an integer type.
-Attribute types (not strictly enforced, except for the key attribute):
I = integer
A = alphabetic
F = float
-Any incorrectly typed commands or records will send the user back to the input line (>>>).

WARNING!
-If the dataCSV.txt file gets overwritten incorrectly, or begins without being properly filled out, the program will not work as intended.