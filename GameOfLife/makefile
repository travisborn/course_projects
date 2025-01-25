TARGET = GameofLife

$(TARGET): $(TARGET).o
	g++ $(TARGET).o -o $(TARGET) -lncurses

$(TARGET).o: $(TARGET).cpp
	g++ -c $(TARGET).cpp

.PHONY: clean

clean:
	rm $(TARGET).o $(TARGET)