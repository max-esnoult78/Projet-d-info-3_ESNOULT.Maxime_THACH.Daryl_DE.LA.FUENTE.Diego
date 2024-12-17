#!/bin/bash

# --- Variables globales ---
INPUT_FILE=""
STATION_TYPE=""
CLIENT_TYPE=""
CENTRALE_ID=""
OUTPUT_FILE=""
EXECUTABLE="./c-wire"
TMP_DIR="./tmp"
TESTS_DIR="./tests"

# --- Fonctions ---
function afficher_aide() {
    echo "Utilisation : $0 <fichier_csv> <type_station> <type_client> [id_centrale]"
    echo "  - fichier_csv : chemin du fichier d'entrée."
    echo "  - type_station : hvb, hva, lv."
    echo "  - type_client : comp, indiv, all."
    echo "  - id_centrale : (optionnel) identifiant d'une centrale spécifique."
    echo "Options supplémentaires :"
    echo "  -h : Afficher cette aide."
    exit 0
}

function verifier_arguments() {
    if [[ "$1" == "-h" ]]; then
        afficher_aide
    fi

    if [[ "$#" -lt 3 ]]; then
        echo "Erreur : Nombre d'arguments insuffisant."
        afficher_aide
    fi

    INPUT_FILE="$1"
    STATION_TYPE="$2"
    CLIENT_TYPE="$3"
    CENTRALE_ID="$4"

    # Validation des types
    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "Erreur : Fichier d'entrée introuvable."
        exit 1
    fi

    if [[ "$STATION_TYPE" != "hvb" && "$STATION_TYPE" != "hva" && "$STATION_TYPE" != "lv" ]]; then
        echo "Erreur : Type de station invalide. Options : hvb, hva, lv."
        exit 1
    fi

    if [[ "$CLIENT_TYPE" != "comp" && "$CLIENT_TYPE" != "indiv" && "$CLIENT_TYPE" != "all" ]]; then
        echo "Erreur : Type de client invalide. Options : comp, indiv, all."
        exit 1
    fi

    # Restrictions pour HVB et HVA
    if [[ ("$STATION_TYPE" == "hvb" || "$STATION_TYPE" == "hva") && "$CLIENT_TYPE" != "comp" ]]; then
        echo "Erreur : Pour HVB et HVA, seuls les clients 'comp' sont valides."
        exit 1
    fi
}

function preparer_dossiers() {
    mkdir -p "$TMP_DIR" "$TESTS_DIR/$STATION_TYPE/$CLIENT_TYPE"
    rm -rf "$TMP_DIR/*"
    echo "Dossiers préparés."
}

function compiler_programme() {
    echo "Compilation du programme C..."
    if [[ ! -f "$EXECUTABLE" ]]; then
        gcc -Wall -Wextra -O2 -o c-wire c-wire3.c
        if [[ $? -ne 0 ]]; then
            echo "Erreur : La compilation a échoué."
            exit 1
        fi
    else
        echo "Programme C déjà compilé."
    fi
}

function executer_programme() {
    echo "Exécution du programme avec les paramètres suivants :"
    echo "  Fichier d'entrée : $INPUT_FILE"
    echo "  Type de station : $STATION_TYPE"
    echo "  Type de client : $CLIENT_TYPE"
    [[ -n "$CENTRALE_ID" ]] && echo "  ID Centrale : $CENTRALE_ID"

    # Définir le nom de fichier de sortie
    OUTPUT_FILE="$TESTS_DIR/$STATION_TYPE/$CLIENT_TYPE/output.csv"

    # Gérer les doublons : sauvegarder les fichiers existants avec un timestamp
    if [[ -f "$OUTPUT_FILE" ]]; then
        mv "$OUTPUT_FILE" "${OUTPUT_FILE%.csv}_$(date +%Y%m%d%H%M%S).csv"
        echo "Ancien fichier sauvegardé avec timestamp."
    fi

    # Exécution du programme C
    START_TIME=$(date +%s.%N)
    ./c-wire "$INPUT_FILE" "$STATION_TYPE" "$CLIENT_TYPE" "$OUTPUT_FILE" "$CENTRALE_ID"
    END_TIME=$(date +%s.%N)
    DURATION=$(echo "$END_TIME - $START_TIME" | bc)

    if [[ $? -ne 0 ]]; then
        echo "Erreur : Le programme C a rencontré un problème."
        exit 1
    fi

    echo "Traitement terminé en $DURATION secondes."
    echo "Fichier de sortie : $OUTPUT_FILE"
}

# --- Script Principal ---
if [[ "$#" -lt 3 ]]; then
    afficher_aide
fi

# Vérification des arguments
verifier_arguments "$@"

# Préparer les dossiers nécessaires
preparer_dossiers

# Compiler le programme C si nécessaire
compiler_programme

# Exécuter le programme C
executer_programme
