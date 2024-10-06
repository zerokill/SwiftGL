# Variables
CC = gcc
SWIFTC = swiftc
CFLAGS = -O3 -c -I/opt/homebrew/include -DGL_SILENCE_DEPRECATION
SWIFTFLAGS = -O -I Modules -I csrc -Xcc -I/usr/local/include -Xcc -I/opt/homebrew/include -L /opt/homebrew/lib -lglfw -framework OpenGL -Xcc -DGL_SILENCE_DEPRECATION
CSOURCES = $(wildcard csrc/*.c)
COBJECTS = $(CSOURCES:.c=.o)
#SWIFTSOURCES = main.swift shadertoy.swift globals.swift benchmark.swift stats.swift graphics.swift
SWIFTSOURCES = $(wildcard swiftsource/*.swift)
TARGET = app

# Default target
all: $(TARGET)

# Compile C source files
csrc/%.o: csrc/%.c
	$(CC) $(CFLAGS) $< -o $@

# Compile Swift code and link
$(TARGET): $(SWIFTSOURCES) $(COBJECTS)
	$(SWIFTC) $(SWIFTSOURCES) $(COBJECTS) $(SWIFTFLAGS) -o $(TARGET)

# Clean up
clean:
	rm -f $(COBJECTS) $(TARGET)

