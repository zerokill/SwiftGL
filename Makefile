# Variables
CC = gcc
SWIFTC = swiftc
CFLAGS = -c -I/opt/homebrew/include -DGL_SILENCE_DEPRECATION
SWIFTFLAGS = -I Modules -I src -Xcc -I/usr/local/include -Xcc -I/opt/homebrew/include -L /opt/homebrew/lib -lglfw -framework OpenGL -Xcc -DGL_SILENCE_DEPRECATION
CSOURCES = $(wildcard src/*.c)
COBJECTS = $(CSOURCES:.c=.o)
SWIFTSOURCES = main.swift shadertoy.swift
TARGET = app

# Default target
all: $(TARGET)

# Compile C source files
src/%.o: src/%.c
	$(CC) $(CFLAGS) $< -o $@

# Compile Swift code and link
$(TARGET): $(SWIFTSOURCES) $(COBJECTS)
	$(SWIFTC) $(SWIFTSOURCES) $(COBJECTS) $(SWIFTFLAGS) -o $(TARGET)

# Clean up
clean:
	rm -f $(COBJECTS) $(TARGET)

