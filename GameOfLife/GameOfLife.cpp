//version with references

#include <iostream>
#include <vector>
#include <ncurses.h>
#include <thread>
#include <chrono>

/* 
   nCurses stuff:

   initscr(); - enters curses mode
   refresh(); - refreshes the screen, when you draw the board remember to refresh
   getch(); - pauses until you press a key (ch)
   endwin(); - exits curses mode
   mvprintw(y, x, "%c", M[y][x] == 1 ? 'X' : ' ');
   noecho(); - control if we see keys pressed - copy all this below
   cbreak(); - control if we see keys pressed
   keypad(stdscr, TRUE); - 
   curs_set(0); - 
   mouseinterval(3); - 
   mousemask(ALL_MOUSE_EVENTS, NULL); - copy all this above
   attron(A-REVERSE); - flip color - white to black - black to white

   MEVENT event??
*/

using namespace std;

using VEC = vector<char>;
using BOARD = vector<VEC>;

const char ALIVE = '#';
const char DEAD = ' ';

void enterNcurses(){
    initscr ();
    noecho();
    cbreak();
    keypad(stdscr, TRUE);
    curs_set(0);
    mouseinterval(3);
    mousemask(ALL_MOUSE_EVENTS, NULL);
}

void exitNcurses(){
    endwin();
}

BOARD createBoard(){
	//create the board
	int row = 24, col = 80;
	
	//initial board to all dead
	BOARD board (row, VEC(col, DEAD));
	
	return board;
}

int numGen(){
	// get the number of desired generations to do
	int gen = 50;
	
	cout << "Enter a number for the amount of generations to show.\n"\
    "Choose a number greater than zero, or enter '0' to use the default(50): ";
	cin >> gen;
	cout << endl;
	
	if (gen <= 0){
		gen = 50;
	}
	return gen;
}

void setBoard(BOARD &board){
    //go to configuration mode to click on tiles to make them alive for the game
    MEVENT event; //need this for mouse click events

    while (true){
        int user = getch();
        switch(user){
            case KEY_MOUSE:
                if (getmouse(&event) == OK){
                    if (event.bstate & BUTTON1_PRESSED){
                        //need to deal with mouse clicks off of the board
                        if (event.y < 0 || event.y >= board.size() || event.x < 0 || event.x >= board[0].size()){
                            continue;
                        }
                        if (board[event.y][event.x] == DEAD){
                            mvprintw(event.y, event.x, "#");
                            board[event.y][event.x] = ALIVE;
                            refresh;
                        }
                        else{
                            mvprintw(event.y, event.x, " ");
                            board[event.y][event.x] = DEAD;
                            refresh;
                        }
                    }
                }
                break;
            case 'q' :
                return;
            }
        }
    }

int numLiveCells(int r, int c, BOARD b){
	int numLive = 0; //count of live cells in surrounding 8 locations
	
	for (int row = r - 1; row <= r + 1; row++){
		for (int col = c - 1; col <= c + 1; col++){
			if ((row == r && col == c) || (row < 0 || row >= b.size() || col < 0 || col >= b[0].size())){
				continue; //skip when on the cell being looked at or out of bounds
			}
			if (b[row][col] == ALIVE){
				numLive++; //if the cell being checked is alive count goes up
			}
		}
	}
	return numLive;
}

void nextGen(BOARD &b){
	BOARD nextBoard (b.size(), VEC(b[0].size(), DEAD));
	int numLive;
	
	for (int row = 0; row < b.size(); row++){
		for (int col = 0; col < b[0].size(); col++){
			numLive = numLiveCells(row, col, b);
			if (b[row][col] == ALIVE){
				//any live cell with 2 or 3 neighbours survives
				if (numLive == 2 || numLive == 3){
					nextBoard[row][col] = ALIVE;
				}
				//all other live cells die
				else{
					nextBoard[row][col] = DEAD;
				}
			}
			if (b[row][col] == DEAD){
				//any dead cell with 3 neighbours becomes alive
				if (numLive == 3){
					nextBoard[row][col] = ALIVE;
				}
				//all other cells stay dead
				else {
					nextBoard[row][col] = DEAD;
				}
			}
		}
	}
	b = nextBoard;
}

void frameByFrameDraw(BOARD &board, int numGen){
    //manually draw the next board with curses
	while (numGen > 0){
		nextGen(board);

        for (auto r = 0; r < board.size(); r++){
            for (auto c = 0; c < board[0].size(); c++){
                mvprintw(r, c, "%c", board[r][c] == DEAD? DEAD : ALIVE);
                refresh();
            }
        }
        numGen--;
        if (getch() == 'q'){ //need to hit q to move to next board
            break;
        }
	}
}

void autoDraw(BOARD &board, int numGen){
    //automatically draw the board
    while (numGen > 0){
		nextGen(board);

        for (auto r = 0; r < board.size(); r++){
            for (auto c = 0; c < board[0].size(); c++){
                mvprintw(r, c, "%c", board[r][c] == DEAD? DEAD : ALIVE);
                refresh();
            }
        }
        this_thread::sleep_for(chrono::milliseconds(100));
        numGen--;
	}
}

int main(){
    cout << "\n----------------------------------------------------------------"\
    "-------------------------------------";
    cout << "\nWelcome to the Game of Life!\n\n";

    int gen = numGen();
    BOARD board = createBoard();

    cout << "----------------------------------------------------------------"\
    "-------------------------------------";
    int choice;
    cout << "\nWould you like the generations to advance automatically or manually frame-by-frame?\n"\
    "Press 'q' to quit manual mode early. Enter '0' for automatic mode or enter '1' for manual mode: ";
    cin >> choice;

    cout << "\n----------------------------------------------------------------"\
    "-------------------------------------";
    cout << "\nOnce you enter configuration mode, left click with the mouse "\
    "on a tile to set it as 'alive',\nand left click on an 'alive' tile to erase it.\n\n"\
    "Once you are finished entering the first configuration, hit the 'q' key to start "\
    "the Game of Life.\nPress the spacebar to advance the generations.\n\n"\
    "Enter 'p' to go to the configuration mode: ";

    char moveOn;
    cin >> moveOn;

    enterNcurses();

    //use curses to get the starting configuration of the board with the mouse
    setBoard(board);

    if (choice == 1){
        frameByFrameDraw(board, gen);
    }
    else{
        autoDraw(board, gen);
    }
    
    exitNcurses();
	cout << endl;
	
	return 0;
}