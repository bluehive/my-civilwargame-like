# Civil War Like — Phase 0 build (Makefile + prebuilt raylib)
# Requires: g++, scripts/fetch-raylib.sh (or vendor/raylib-prebuilt)

CXX      ?= g++
CXXFLAGS ?= -std=c++17 -Wall -Wextra -O2
RAYLIB_DIR ?= vendor/raylib-prebuilt

SRC      := src/main.cpp
BIN_DIR  := build
TARGET   := $(BIN_DIR)/civil-war-like

RAYLIB_INC := -I$(RAYLIB_DIR)/include
# Versioned .so paths (no -dev packages required on this host)
SYS_LIBS   := -lm -lpthread -ldl \
	/lib/x86_64-linux-gnu/libGLX.so.0 \
	/lib/x86_64-linux-gnu/libX11.so.6 \
	/lib/x86_64-linux-gnu/libGLdispatch.so.0

.PHONY: all deps compile run smoke clean help

all: compile

help:
	@echo "targets: deps | compile | run | smoke | clean"
	@echo "  deps     fetch raylib into vendor/"
	@echo "  compile  build $(TARGET)"
	@echo "  run      launch window (interactive)"
	@echo "  smoke    launch with --smoke (auto-close)"

deps:
	@bash scripts/fetch-raylib.sh

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

compile: deps $(TARGET)

# Link flags resolved at recipe time (after deps may have fetched raylib)
$(TARGET): $(SRC) | $(BIN_DIR)
	@if [ -f "$(RAYLIB_DIR)/lib/libraylib.a" ]; then \
	  $(CXX) $(CXXFLAGS) $(RAYLIB_INC) -o $@ $(SRC) \
	    -L"$(RAYLIB_DIR)/lib" -Wl,-rpath,'$$ORIGIN/../vendor/raylib-prebuilt/lib' \
	    "$(RAYLIB_DIR)/lib/libraylib.a" $(SYS_LIBS); \
	elif [ -f "$(RAYLIB_DIR)/lib/libraylib.so" ]; then \
	  $(CXX) $(CXXFLAGS) $(RAYLIB_INC) -o $@ $(SRC) \
	    -L"$(RAYLIB_DIR)/lib" -Wl,-rpath,'$$ORIGIN/../vendor/raylib-prebuilt/lib' \
	    -lraylib $(SYS_LIBS); \
	else \
	  echo "❌ raylib not found under $(RAYLIB_DIR). Run: make deps"; \
	  exit 1; \
	fi
	@echo "✅ built $@"

run: compile
	./$(TARGET)

smoke: compile
	CIVIL_WAR_LIKE_SMOKE=1 ./$(TARGET) --smoke

clean:
	rm -rf $(BIN_DIR)
