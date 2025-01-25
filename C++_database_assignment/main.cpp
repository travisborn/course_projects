#include "common.hpp"

int main(){
    DATA database;

    readFile(database);
    sortData(database);
    commands(database);

    return 0;
}
