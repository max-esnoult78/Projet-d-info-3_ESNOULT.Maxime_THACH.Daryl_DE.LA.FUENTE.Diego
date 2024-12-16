#!/bin/bash

# --- Variables ---
EXECUTABLE="./c-wire"
OUTPUT_DIR="./results"

# --- Affichage de l'aide ---
function afficher_aide() {
    echo "Usage: $0 <csv_file> <station_type> <client_type> <output_file>"
    echo "  - csv_file: Path to the input CSV file."
    echo "  - station_type: hvb, hva, lv."
    echo "  - client_type: comp, indiv, all."
    echo "  - output_file: Path to the output file."
    exit 0
}

# --- Vérification des arguments ---
function verifier_arguments() {
    if [[ $# -lt 4 ]]; then
        afficher_aide
    fi

    CSV_FILE="$1"
    STATION_TYPE="$2"
    CLIENT_TYPE="$3"
    OUTPUT_FILE="$4"

    if [[ ! -f "$CSV_FILE" ]]; then
        echo "Error: Input CSV file not found."
        exit 1
    fi

    mkdir -p "$OUTPUT_DIR"
}

# --- Compilation ---
function compiler_programme() {
    if [[ ! -f "$EXECUTABLE" ]]; then
        echo "Compiling C program..."
        gcc -o c-wire c-wire.c
        if [[ $? -ne 0 ]]; then
            echo "Error: Compilation failed."
            exit 1
        fi
    fi
}

# --- Exécution ---
function executer_programme() {
    echo "Running the C program..."
    $EXECUTABLE "$CSV_FILE" "$STATION_TYPE" "$CLIENT_TYPE" "$OUTPUT_FILE"
    if [[ $? -ne 0 ]]; then
        echo "Error: Program execution failed."
        exit 1
    fi
    echo "Output generated in $OUTPUT_FILE"
}

# --- Script principal ---
if [[ "$1" == "-h" ]]; then
    afficher_aide
fi

verifier_arguments "$@"
compiler_programme
executer_programme
