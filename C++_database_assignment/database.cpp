#include "common.hpp"

void readFile(DATA &database){ //read from records file to create database
    const char comma[] = ",";
    RECORD record, dataCSV;
    string entry, info;

    fstream csv("dataCSV.txt");

    while (getline(csv, entry)){
        entry.erase(remove(entry.begin(), entry.end(), '\r' ), entry.end()); //stupid windows
        entry.erase(remove(entry.begin(), entry.end(), '\n' ), entry.end()); //windows is stupid
        dataCSV.push_back(entry); //includes commas
    }
    for (auto line : dataCSV){ //this section separates each line on commas
        stringstream attrib(line);
        while (attrib){
            getline(attrib, info, ',');
            record.push_back(info);
        }
        record.pop_back();
        database.push_back(record); //create the actual memory-based database
        record.erase(record.begin(), record.end());
    }
    csv.close();
    return;
}

void writeFile(DATA database){
    RECORD dataCSV;
    DATA tempData = database;

    for (auto rec : tempData){ //loop to add commas in for the file
        for (int i = 0; i < rec.size(); i++){
            if (i < rec.size()-1){
                rec[i].append(",");
                dataCSV.push_back(rec[i]);
            }
            else{
                dataCSV.push_back(rec[i]);
            }
        }
    }
    //remove("dataCSV.txt"); //remove old file
    //fstream csv("dataCSV.txt", ios::app); //create new file (ios::app makes it append to whats already there)
    ofstream csv("dataCSV.txt", ios::trunc);

    int index = 0; //index will keep track of line length for file
    for (auto att : dataCSV){
        if (index == database.front().size()){ //at the end of individual record, so go to next line
            csv << endl;
            index = 0;
        }
        index++;
        csv << att; //add next attribute to file
    }
    csv.close();
    return;
}

void sortData(DATA &database){
    RECORD schema = database.front(); //get rid of schema and types lines before sorting
    database.pop_front();
    RECORD types = database.front();
    database.pop_front();

    for (auto i : schema){
        for (auto &ch : i){
            ch = toupper(ch);
        }
    }

    for (auto i : types){
        for (auto &ch : i){
            ch = toupper(ch);
        }
    }

    //list container's special sort with a lambda expression for the compare function
    database.sort([](const RECORD &first, const RECORD &second) {return stoi(first.front()) < stoi(second.front());});
    
    database.push_front(types); //put schema and types lines back in
    database.push_front(schema);
    return;
}

void commands(DATA &database){
    static int done = 0;
    while (!done){
        DATA tempData = database;
        //database will have new records added, or requested records deleted, but no other changes
        RECORD schema = tempData.front(); //separate out schema line
        tempData.pop_front();
        RECORD types = tempData.front(); //separate out types line
        tempData.pop_front(); //tempData will have only records here, no schema or types

        static int firstTime = 1;
        if (firstTime){

            firstTime = 0;

            cout << "\n\n-------------------------------------------DATABASE MANAGER----------------------------------------------------\n\n"
                    "Please enter a command by the arrows (>>>). The command must be of the form: <verb> <fieldname(s)> <clause>\n\n"\
                    "Where each word is separated by 1 or more spaces. (Do not include the '<' or '>')\n\n"\
                    "If there is more than one fieldname, they are joined to each other using a comma with no space between them.\n\n"\
                   "The clause has the form WHERE keyfield=keyvalue, where keyfield is the name of the key field for this database\n"\
                    "and keyvalue is a value for the key.\n\nCharacters can be upper or lower case.\n\n"\
                    "Example: SELECT FNAME,LNAME WHERE ID=23\n\nAvailable verbs are:\n\n"\
                    "CLOSE\nThis command takes no fields or clause. It will write the database to a CSV (dataCSV.txt) file,\n"\
                    "and then quit the program.\n\n"\
                    "DELETE\nThis command takes no fieldname but has a single clause that identifies which records/rows to delete.\n\n"\
                    "SELECT\nThis command will take one or more fieldnames and an optional clause.\nIf no clause "\
                    "is given, the command will display the values associated with the fieldnames\nfor ALL records/rows in the database.\n"\
                    "If a clause is present, it will display the values for the requested fieldnames.\n\n"\
                    "ADD\nThis command takes a list of comma,separated values followed by a clause identical to "\
                   "DELETE and SELECT.\nThe comma separated values will be added to the database using the key provided in the clause.\n\n"\
                    "DATA\nThis command takes no fields or clause. It will display the current database as it would be written into the CSV file.\n";
        }
        cout << "\n\nCommands: CLOSE, DELETE, SELECT, ADD, DATA\n";
        cout << "Fieldnames:";
        for (auto name : schema){
            cout << " " << name;
        }
        cout << "\n\n>>> ";

        RECORD command;
        string input, verb;
        getline(cin, input);
        stringstream temp(input);
        int count = 0;
        while (getline(temp, verb, ' ')){
            if (count++ == 1){
                command.push_back(verb);
                continue;
            }
            for (auto &ch : verb){
                ch = toupper(ch);
            }
            command.push_back(verb);
        }

        string keyFormat = database.front().front();
        keyFormat += "[=].+";
        regex keyCheck(keyFormat);

        string recFormat = "";
        for (int i = 0; i < database.front().size() - 2; i++){
            recFormat += ".+,";
        }
        recFormat += ".+";
        //recFormat += "[[a-zA-Z0-9.]*]*";
        regex recCheck(recFormat);
        regex selectCheck(".+");
    
        if (command[0] == "CLOSE"){
            writeFile(database);
            cout << "\nThe CSV file dataCSV.txt has been updated. Reopen the file to view the changes.\n\n"\
                    "--------------------------------------------------------------------------------------------------------------\n\n";
            done = 1;
        }
        else if (command[0] == "DELETE"){
            if (command.size() == 3 && (command[1] == "WHERE" || command[1] == "where") && regex_match(command[2], keyCheck)){
                deleteRec(database, command);
            }
            else{
                cout << "Not a valid DELETE command, must be: DELETE WHERE keyfield=keyvalue\n";
            }
        }
        else if (command[0] == "SELECT"){
            if (command.size() == 2 && regex_match(command[1], selectCheck)){
                selectRec(database, command, false);
            }
            else if (command.size() == 4 && regex_match(command[1], selectCheck) && command[2] == "WHERE" && regex_match(command[3], keyCheck)){
                selectRec(database, command, true);
            }
            else {
                cout << "Not a valid SELECT command, must be: SELECT as,many,fields,etc WHERE keyfield=keyvalue\n"\
                "                                 or: SELECT as,many,fields,etc\n";
            }
        }
        else if (command[0] == "ADD"){
            if (command.size() == 4 && regex_match(command[1], recCheck) && command[2] == "WHERE" && regex_match(command[3], keyCheck)){
                addRec(database, command);
            }
            else{
                cout << "Not a valid ADD command, must be: ADD as,many,fields,etc WHERE keyfield=keyvalue\n";
            }
        }
        else if (command[0] == "DATA"){
            display(database);
        }
        else{
            cout << command[0] << " is not a valid command." << endl;
        }
    }
    return;
}

void deleteRec(DATA &database, RECORD command){
    string clause;
    RECORD key, record;
    stringstream temp(command[2]);
    
    while (getline(temp, clause, '=')){
        key.push_back(clause);
    }

    if (key[0] != database.front().front()){
        cout << "Not a valid keyfield.\n";
        return;
    }

    for (auto iter = database.begin(); iter != database.end(); ++iter){
        //record = *iter;
        if (((*iter)[0] == key[1])){
            cout << "Entry where " << key[0] << "=" << key[1] << " was deleted.";
            database.erase(iter);
            sortData(database);
            return;
        }
    }
    cout << "The record was not in the database.\n";
    return;
}

void selectRec(DATA &database, RECORD command, bool hasClause){
    string clause, col;
    RECORD fieldCol, key, columns, schema = database.front();
    int size =schema.size();
    COLUMNS fieldnames(size, fieldCol);

    for (auto &i : schema){
        for (auto &ch : i){
            ch = toupper(ch);
        }
    }
    
    if (hasClause){
        stringstream temp(command[3]);
    
        while (getline(temp, clause, '=')){
            key.push_back(clause);
        }
        if (key[0] != database.front().front()){
            cout << "Not a valid keyfield.\n";
            return;
        }
    }
    
    stringstream info(command[1]);
    while (getline(info, col, ',')){
        for (auto &ch : col){
            ch = toupper(ch);
        }
        columns.push_back(col);
    }

    for (auto col : columns){
        bool found = 0;
        for (auto name : schema){
            if (col == name){
                found = 1;
            }
            
        }
        if (!found){
            cout << col << " is not a fieldname.\n";
            return;
        }
    }

    for (auto rec : database){
        for (int i = 0; i < rec.size(); i++){
            for (auto &str : rec){
                for (auto &ch : str){
                    ch = toupper(ch);
                }
            }
            fieldnames[i].push_back(rec[i]);
        }
    }

    for (auto col : fieldnames){
        for (int i = 0; i < fieldnames.size(); i++){
            fieldnames[i][1] = "----------";
        }
    }

        cout << "i am here" << endl;

    if (hasClause){
        for (int i = 2; i < fieldnames.front().size(); i++){
            if (fieldnames[0][i] == key[1]){
                for (auto col : fieldnames){
                    for (auto name : columns){
                        if (col[0] == name){
                            cout << endl << name << "\n----------\n";
                            cout << col[i] << endl;
                        }
                    }
                }
                return;
            }
        }
        cout << "The record was not in the database.\n";
    }
    else{
        for (auto col : fieldnames){
            for (auto name : columns){
                if (col[0] == name){
                    cout << endl;
                    for (auto item : col){
                        cout << item << endl;
                    }
                }
            }
        }
    }
    return;
}

void addRec(DATA &database, RECORD command){
    RECORD key, record;
    string clause, newRec;
    stringstream temp(command[3]), tempRec(command[1]);
    
    while (getline(temp, clause, '=')){
        key.push_back(clause);
    }

    //check if key already present
    for (auto rec : database){
        if (key[1] == rec.front()){
            cout << "That key is already in the database.\n";
            return;
        }
    }

    record.push_back(key[1]);
    while (getline(tempRec, newRec, ',')){
        record.push_back(newRec);
    }

    database.push_back(record);
    cout << "Entry where " << key[0] << "=" << key[1] << " was added.";
    
    sortData(database);
    return;
}

void display(DATA database){
    cout << endl;

    string temp;

    for (auto rec : database){
        temp = rec.back();
        rec.pop_back();
        for (auto att : rec){
            cout << att << ',';
        }
        cout << temp << endl;
    }
    return;
}