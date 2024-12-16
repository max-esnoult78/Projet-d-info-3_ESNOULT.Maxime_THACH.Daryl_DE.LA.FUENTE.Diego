#!/bin/bash

INPUT_FILE=""
STATION_TYPE=""
CLIENT_TYPE=""
OUTPUT_FILE=""
EXECUTABLE="./c-wire"

function afficher_aide() {
    echo "Usage: $0 <csv_file> <station_type> <client_type> [centrale_id]"
    echo "  - csv_file: Path to the input CSV file."
    echo "  - station_type: hvb, hva, lv."
    echo "  - client_type: comp, indiv, all."
    echo "  - centrale_id: Optional, filter by centrale ID."
    exit 0
}

function verifier_arguments() {
    if [[ "$#" -lt 3 ]]; then
        afficher_aide
    fi

    INPUT_FILE="$1"
    STATION_TYPE="$2"
    CLIENT_TYPE="$3"

    if [[ "$STATION_TYPE" != "hvb" && "$STATION_TYPE" != "hva" && "$STATION_TYPE" != "lv" ]]; then
        echo "Error: Invalid station type. Options: hvb, hva, lv."
        exit 1
    fi

    if [[ "$CLIENT_TYPE" != "comp" && "$CLIENT_TYPE" != "indiv" && "$CLIENT_TYPE" != "all" ]]; then
        echo "Error: Invalid client type. Options: comp, indiv, all."
        exit 1
    fi

    OUTPUT_FILE="./results/${STATION_TYPE}_${CLIENT_TYPE}.csv"
}

function compiler_programme() {
    if [[ ! -f "$EXECUTABLE" ]]; then
        echo "Compiling C program..."
        gcc -o c-wire c-wire.c
        if [[ $? -ne 0 ]]; then
            echo "Compilation failed."
            exit 1
        fi
    fi
}

function executer_programme() {
    echo "Running C program..."
    ./c-wire "$INPUT_FILE" "$STATION_TYPE" "$CLIENT_TYPE" "$OUTPUT_FILE"
    if [[ $? -ne 0 ]]; then
        echo "Error during execution."
        exit 1
    fi
    echo "Output written to $OUTPUT_FILE"
}

# Main Script
if [[ "$1" == "-h" ]]; then
    afficher_aide
fi

verifier_arguments "$@"
compiler_programme
executer_programme
