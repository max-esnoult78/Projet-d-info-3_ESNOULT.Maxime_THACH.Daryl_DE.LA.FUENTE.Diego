# Nom de l'exécutable
EXEC = c-wire

# Fichiers sources
SRC = c-wire.c

# Options de compilation
CFLAGS = -Wall -Wextra -O2

# Commandes
CC = gcc

# Règles de compilation
all: $(EXEC)

$(EXEC): $(SRC)
	$(CC) $(CFLAGS) -o $(EXEC) $(SRC)

# Nettoyage des fichiers générés
clean:
	rm -f $(EXEC)

.PHONY: all clean
