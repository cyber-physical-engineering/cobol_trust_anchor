###############################################################################
# Makefile for COBOL Trust Anchor
# 
# Big Data Plumbing / HealthSec Alliance
# Local development build (without Docker)
###############################################################################

CC = gcc
COBC = cobc
CFLAGS = -c -fPIC -Wall
COBFLAGS = -x -Wall
LDFLAGS = -lssl -lcrypto

# Source files
C_SRC = hasher.c
COB_SRC = anchor.cbl
C_OBJ = hasher.o
TARGET = trust-anchor

# Default target
all: $(TARGET)

# Compile C bridge
$(C_OBJ): $(C_SRC)
	$(CC) $(CFLAGS) $(C_SRC) -o $(C_OBJ) -lcrypto

# Compile COBOL and link with C
$(TARGET): $(C_OBJ) $(COB_SRC)
	$(COBC) $(COBFLAGS) -o $(TARGET) $(COB_SRC) $(C_OBJ) $(LDFLAGS)

# Run the program
run: $(TARGET)
	./$(TARGET)

# Clean build artifacts
clean:
	rm -f $(C_OBJ) $(TARGET) *.c *.h *.i *.lst *.sym immutable_log.txt

# Install dependencies (Debian/Ubuntu)
install-deps:
	sudo apt-get update
	sudo apt-get install -y gnucobol libssl-dev gcc libc6-dev

# Docker build
docker-build:
	docker build -t cobol-trust-anchor .

# Docker run
docker-run:
	docker run --rm cobol-trust-anchor

.PHONY: all run clean install-deps docker-build docker-run

