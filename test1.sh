#!/bin/bash

EXECUTABLE="./c-wire"
RESULTS_DIR="./results"

function afficher_aide() {
    echo "Usage: $0 <data_file> <station_type> <client_type> <output_file>"
    echo "  - data_file: Path to the input data file (e.g., c-wire_v00.dat)."
    echo "  - station_type: Type of station (e.g., hvb, hva, lv)."
    echo "  - client_type: Type of client (e.g., comp, indiv, all)."
    echo "  - output_file: Name of the output file."
    exit 0
}

function verifier_arguments() {
    if [[ $# -lt 4 ]]; then
        afficher_aide
    fi
    if [[ ! -f "$1" ]]; then
        echo "Erreur : Le fichier $1 est introuvable."
        exit 1
    fi
}

function compiler_programme() {
    if [[ ! -f "$EXECUTABLE" ]]; then
        echo "Compilation du programme C..."
        gcc -o c-wire c-wire.c
        if [[ $? -ne 0 ]]; then
            echo "Erreur lors de la compilation du programme C."
            exit 1
        fi
    fi
}

function executer_programme() {
    mkdir -p "$RESULTS_DIR"
    local INPUT_FILE=$1
    local STATION_TYPE=$2
    local CLIENT_TYPE=$3
    local OUTPUT_FILE=$4

    echo "Exécution du programme avec les paramètres :"
    echo "  Fichier d'entrée : $INPUT_FILE"
    echo "  Type de station : $STATION_TYPE"
    echo "  Type de client : $CLIENT_TYPE"
    echo "  Fichier de sortie : $RESULTS_DIR/$OUTPUT_FILE"

    ./"$EXECUTABLE" "$INPUT_FILE" "$STATION_TYPE" "$CLIENT_TYPE" "$RESULTS_DIR/$OUTPUT_FILE"
    if [[ $? -ne 0 ]]; then
        echo "Erreur lors de l'exécution du programme."
        exit 1
    fi

    echo "Résultat écrit dans : $RESULTS_DIR/$OUTPUT_FILE"
}

# Main script
if [[ "$1" == "-h" ]]; then
    afficher_aide
fi

verifier_arguments "$@"
compiler_programme
executer_programme "$@"
