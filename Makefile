# Makefile for TEST-GPIB-Terminal
# Generated from CMakeLists.txt for IDE usage

# ============================================================================
# Project Configuration
# ============================================================================
PROJECT_NAME ?= TEST-GPIB-Terminal
VERSION ?= 0.2

# Compiler and flags
CXX ?= g++
CXXFLAGS ?= -std=c++20 -fPIC -Wall -Wextra

# Get wxWidgets config
WX_CONFIG ?= wx-config
WX_CXXFLAGS = $(shell $(WX_CONFIG) --cxxflags)
WX_LIBS = $(shell $(WX_CONFIG) --libs core,base,adv,net,richtext)

# ============================================================================
# Directories and Paths
# ============================================================================
SRC_DIR ?= src
INCLUDE_DIR ?= include
MODE ?= Release
OBJ_DIR ?= obj/$(MODE)
BIN_DIR ?= bin/$(MODE)
BUILD_DIR := $(BIN_DIR)
THIRD_PARTY_DIR = third-party

# Boost (header-only)
BOOST_INCLUDE = $(THIRD_PARTY_DIR)/boost_1_90_0

# Mathplot
MATHPLOT_SRC = $(THIRD_PARTY_DIR)/mathplot.cpp
MATHPLOT_INCLUDE = $(THIRD_PARTY_DIR)

# FTDI
ifeq ($(OS),Windows_NT)
    FTDI_INCLUDE = $(THIRD_PARTY_DIR)/FTDI
    FTDI_LIB = $(THIRD_PARTY_DIR)/FTDI/ftd2xx.lib
else
    FTDI_INCLUDE = /usr/include
    FTDI_LIB = -lftd2xx
endif

# Output executable
EXECUTABLE ?= $(BIN_DIR)/$(PROJECT_NAME)
CODEBLOCKS_PROJECT_NAME ?= GPIB-Measurement-Tool
CODEBLOCKS_EXECUTABLE ?= $(BIN_DIR)/$(CODEBLOCKS_PROJECT_NAME)

# ============================================================================
# Include Directories
# ============================================================================
INCLUDES = -I$(INCLUDE_DIR) \
           -I$(INCLUDE_DIR)/data \
           -I$(INCLUDE_DIR)/gui \
           -I$(INCLUDE_DIR)/gui/FunctionWindow \
           -I$(INCLUDE_DIR)/gui/helpTab \
           -I$(INCLUDE_DIR)/gui/MesurementWindow \
           -I$(INCLUDE_DIR)/gui/MesurementWindow/InputDialog \
           -I$(INCLUDE_DIR)/gui/SettingsWindow \
           -I$(INCLUDE_DIR)/gui/TerminalWindow \
           -I$(INCLUDE_DIR)/hardware \
           -I$(INCLUDE_DIR)/Plotter \
           -I$(SRC_DIR) \
           -I$(SRC_DIR)/data \
           -I$(SRC_DIR)/gui \
           -I$(SRC_DIR)/gui/FunctionWindow \
           -I$(SRC_DIR)/gui/helpTab \
           -I$(SRC_DIR)/gui/MesurementWindow \
           -I$(SRC_DIR)/gui/MesurementWindow/InputDialog \
           -I$(SRC_DIR)/gui/SettingsWindow \
           -I$(SRC_DIR)/gui/TerminalWindow \
           -I$(SRC_DIR)/hardware \
           -I$(SRC_DIR)/Plotter \
           -I$(MATHPLOT_INCLUDE) \
           -I$(BOOST_INCLUDE) \
           -I$(FTDI_INCLUDE) \
           $(WX_CXXFLAGS)

# ============================================================================
# Compiler Flags
# ============================================================================
DEFINES = -DwxUSE_GUI=1
ifeq ($(OS),Windows_NT)
    DEFINES += -DWXUSINGDLL -D_WIN32_WINNT=0x0A00 -D_CRT_SECURE_NO_WARNINGS
endif

CXXFLAGS += $(DEFINES)

ifeq ($(MODE),Debug)
	MODE_CXXFLAGS = -O0 -g3 -DDEBUG
else
	MODE_CXXFLAGS = -O2 -DNDEBUG
endif

# ============================================================================
# Source Files
# ============================================================================
# Recursive wildcard helper to auto-pick up new source files after refactors.
rwildcard = $(foreach d,$(wildcard $1/*),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

SRC_SOURCES = $(call rwildcard,$(SRC_DIR),*.cpp)
ALL_SOURCES = $(SRC_SOURCES) $(MATHPLOT_SRC)

# Object files
OBJECTS = $(patsubst %.cpp,$(OBJ_DIR)/%.o,$(ALL_SOURCES))

# ============================================================================
# Linking
# ============================================================================
LDFLAGS += $(WX_LIBS) $(FTDI_LIB)

# ============================================================================
# Targets
# ============================================================================
.PHONY: all clean rebuild run help Debug Release cleanDebug cleanRelease

all: $(EXECUTABLE)

# Code::Blocks uses explicit target names like "Debug" and "Release".
Debug:
	@$(MAKE) MODE=Debug all

Release:
	@$(MAKE) MODE=Release all

# Create directories
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(OBJ_DIR)
	@mkdir -p $(OBJ_DIR)/src/data
	@mkdir -p $(OBJ_DIR)/src/gui
	@mkdir -p $(OBJ_DIR)/src/gui/FunctionWindow
	@mkdir -p $(OBJ_DIR)/src/gui/helpTab
	@mkdir -p $(OBJ_DIR)/src/gui/MesurementWindow
	@mkdir -p $(OBJ_DIR)/src/gui/TerminalWindow
	@mkdir -p $(OBJ_DIR)/src/hardware
	@mkdir -p $(OBJ_DIR)/src/Plotter
	@mkdir -p $(OBJ_DIR)/third-party

# Compilation rule
$(OBJ_DIR)/%.o: %.cpp | $(BUILD_DIR)
	@echo "Compiling: $<"
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(MODE_CXXFLAGS) $(INCLUDES) -c $< -o $@

# Linking
$(EXECUTABLE): $(OBJECTS)
	@echo "Linking: $(PROJECT_NAME)"
	@mkdir -p $(BIN_DIR)
	$(CXX) -o $(EXECUTABLE) $(OBJECTS) $(LDFLAGS)
	@if [ "$(notdir $(EXECUTABLE))" != "$(CODEBLOCKS_PROJECT_NAME)" ]; then \
		cp -f "$(EXECUTABLE)" "$(CODEBLOCKS_EXECUTABLE)"; \
		echo "Code::Blocks alias: $(CODEBLOCKS_EXECUTABLE)"; \
	fi
	@echo "Build complete: $(EXECUTABLE)"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf bin obj build

cleanDebug:
	@echo "Cleaning Debug artifacts..."
	@rm -rf bin/Debug obj/Debug build/Debug

cleanRelease:
	@echo "Cleaning Release artifacts..."
	@rm -rf bin/Release obj/Release build/Release

# Rebuild
rebuild: clean all

# Run executable
run: all
	@echo "Running $(PROJECT_NAME)..."
	@$(EXECUTABLE)

# Help
help:
	@echo "$(PROJECT_NAME) - Makefile Targets:"
	@echo ""
	@echo "  make              - Build the project (default)"
	@echo "  make Debug        - Build debug configuration"
	@echo "  make Release      - Build release configuration"
	@echo "  make run          - Build and run the executable"
	@echo "  make clean        - Remove all build artifacts"
	@echo "  make cleanDebug   - Remove Debug build artifacts"
	@echo "  make cleanRelease - Remove Release build artifacts"
	@echo "  make rebuild      - Clean and build from scratch"
	@echo "  make help         - Show this help message"
	@echo ""
	@echo "Configuration:"
	@echo "  Build Mode:       $(MODE)"
	@echo "  C++ Standard:     C++20"
	@echo "  Compiler:         $(CXX)"
	@echo "  Build Directory:  $(BUILD_DIR)"
	@echo "  Executable:       $(EXECUTABLE)"
	@echo "  wxWidgets:        $(WX_CONFIG)"
	@echo ""

.DEFAULT_GOAL := all
