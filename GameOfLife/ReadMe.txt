Travis Born
4210344

CS2010 - Lab #3 Program #2 - Game of Life

README
___________________________________________________________________________________________

INCLUDED FILES:
-GameOfLife.cpp, the main file that contains the main and other functions. Contains the createBoard(), setBoard(), nextGen(), and main() functions, etc. that are required to run the program.
-this Readme
-makefile
___________________________________________________________________________________________

COMPILATION:
-This program is designed to be run in a Linux shell, such as Ubuntu. Executing in any other place might yield unexpected results.
-Must have the nCurses library properly installed on the system used to run the program.
-Compile and link the GameOfLife.cpp file with the nCurses library by typing the following command in the command prompt line with the folder containing these files as the current working directory:
 
 $ make

RUN:
-To run the program, after typing the above command into the command prompt line enter the following command:
 
 $ ./GameOfLife
___________________________________________________________________________________________

!WARNING!
-When prompted, please enter expected values only! Entering unexpected values may cause unexpected results or errors.
___________________________________________________________________________________________

DESCRIPTION:

-This program will run a version of the Game of Life, a cellular automaton devised by the British mathematician John Horton Conway in 1970. 

-This program will create a board that is 80 columns wide and 24 rows high.
-ALIVE tiles are denoted with a #.
-DEAD tiles are shown with empty space.
-The user will first be prompted to enter a number greater than 0 to choose the number of generations to show. PLEASE ENTER EXPECTED VALUES ONLY.
-The user will be prompted to enter 0 or 1 to choose whether the generations will advance automatically or manually (when the user presses any key other than q).
-The user can end manual mode early by pressing the q key, and the user can advance the generations by one generation by presseing the spacebar. PLEASE ENTER EXPECTED VALUES ONLY.
-Once the user has selected a mode, they will be able to press the p key to enter configuration mode.
-In configuration mode, the user will be able to use the mouse to click on tiles within the 80x24 board to change the state of the tile to ALIVE. The user can click on an ALIVE tile again to erase it. Clicking outside the 80x24 board has no effect.
-Press the q key to exit configuration mode when finished entering the first generation.
-The Game of Life will begin automatically. If the user chose auto mode, then the generations will advance automatically. If the user chose manual mode, then the user will need to press the spacebar to advance the generations, or press the q key to end the program early.

RULES FOR THE GAME OF LIFE:
-Every tile interacts with its eight neighbours(or as many as are within the board limits). The neighbours are the tiles that are horizontally, vertically, or diagonally adjacent.
-For each generation, the following occurs:

1. Any ALIVE tile with fewer than two live neighbours turns DEAD.
2. Any ALIVE tile with two or three live neighbours stays ALIVE.
3. Any ALIVE tile with more than three live neighbours turns DEAD.
4. Any DEAD tile with exactly three ALIVE neighbours turns ALIVE.

TIPS:
-There are many patterns that have interesting effects. See the Conway's Game of Life wikipedia page for more information.
-https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life