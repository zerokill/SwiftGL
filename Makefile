# ===================================================================
#                           Makefile
# ===================================================================
# Description:
#   Build script for compiling C, C++, and Swift sources with OpenGL.
#   Includes ImGui integration and Swift code linking.
#
# Usage:
#   make            # Builds the target application
#   make clean      # Cleans up generated files
# ===================================================================

# -------------------------------
# Variables
# -------------------------------

# Compilers
CC        := gcc
CXX       := g++
SWIFTC    := swiftc

# Directories
C_SRC_DIR       := csrc
SWIFT_SRC_DIR   := swiftsource
IMGUILIB_DIR    := $(C_SRC_DIR)/imgui
IMGUILIB_BACKENDS_DIR := $(IMGUILIB_DIR)/backends
WRAPPER_DIR     := $(C_SRC_DIR)/wrapper

# Source Files
C_SOURCES       := $(wildcard $(C_SRC_DIR)/*.c)
C_OBJECTS       := $(C_SOURCES:.c=.o)

CPP_SOURCES     := $(wildcard $(C_SRC_DIR)/*.cpp)
IMGUILIB_SOURCES := \
    $(IMGUILIB_DIR)/imgui.cpp \
    $(IMGUILIB_DIR)/imgui_draw.cpp \
    $(IMGUILIB_DIR)/imgui_tables.cpp \
    $(IMGUILIB_DIR)/imgui_widgets.cpp \
    $(IMGUILIB_DIR)/imgui_demo.cpp \
    $(IMGUILIB_BACKENDS_DIR)/imgui_impl_opengl3.cpp \
    $(IMGUILIB_BACKENDS_DIR)/imgui_impl_glfw.cpp

WRAPPER_SOURCES := $(wildcard $(WRAPPER_DIR)/*.cpp)
CPP_ALL_SOURCES  := $(CPP_SOURCES) $(IMGUILIB_SOURCES) $(WRAPPER_SOURCES)
CPP_OBJECTS      := $(CPP_ALL_SOURCES:.cpp=.o)

SWIFT_SOURCES    := $(wildcard $(SWIFT_SRC_DIR)/*.swift)

# All Object Files
ALL_OBJECTS      := $(C_OBJECTS) $(CPP_OBJECTS)

# Compiler Flags

## C Flags
CFLAGS           := -O2 -Wall -I/opt/homebrew/include -DGL_SILENCE_DEPRECATION

## C++ Flags
CXXFLAGS         := -std=c++14 -O2 -Wall -fPIC \
                    -I/opt/homebrew/include \
                    -I$(IMGUILIB_DIR) \
                    -I$(IMGUILIB_BACKENDS_DIR) \
                    -I$(WRAPPER_DIR) \
                    -DGL_SILENCE_DEPRECATION

## Swift Flags
SWIFTFLAGS       := -O \
                    -I Modules \
                    -I csrc \
                    -Xcc -I/usr/local/include \
                    -Xcc -I/opt/homebrew/include \
                    -L /opt/homebrew/lib \
                    -lglfw \
                    -framework OpenGL \
                    -Xcc -DGL_SILENCE_DEPRECATION \
                    -lc++

# Linker Flags
LDFLAGS          := -L /opt/homebrew/lib -lglfw -framework OpenGL -lc++

# Target
TARGET           := app

# -------------------------------
# Default Target
# -------------------------------
all: $(TARGET)

# -------------------------------
# Compilation Rules
# -------------------------------

## Compile C source files
$(C_SRC_DIR)/%.o: $(C_SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

## Compile C++ source files (including ImGui and Wrappers)
$(C_SRC_DIR)/%.o: $(C_SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# -------------------------------
# Swift Compilation and Linking
# -------------------------------

$(TARGET): $(SWIFT_SOURCES) $(ALL_OBJECTS)
	$(SWIFTC) $(SWIFT_SOURCES) $(ALL_OBJECTS) $(SWIFTFLAGS) -o $(TARGET)

# -------------------------------
# Clean Target
# -------------------------------
clean:
	rm -f $(ALL_OBJECTS) $(TARGET)

# -------------------------------
# Phony Targets
# -------------------------------
.PHONY: all clean

