#ifndef COMMON_HPP //include guard
#define COMMON_HPP

#include <iostream>
#include <fstream>
#include <utility>
#include <vector>
#include <array>
#include <list>
#include <tuple>
#include <string>
#include <iomanip>
#include <algorithm>
#include <cstdio>
#include <cctype>
#include <climits>
#include <cstring>
#include <sstream>
#include <regex>

using namespace std;

using RECORD = vector<string>;
using DATA = list<RECORD>;
using COMMAND = vector<string>;
using COLUMNS = vector<vector<string>>;

void readFile(DATA &);
void sortData(DATA &);
void writeFile(DATA);
void commands(DATA &);
void deleteRec(DATA &, RECORD);
void selectRec(DATA &, RECORD, bool);
void addRec(DATA &, RECORD);
void display(DATA);

#endif //end of include guard