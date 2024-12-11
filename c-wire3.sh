#!/bin/bash

# --- Variables globales ---
INPUT_FILE=""
STATION_TYPE=""
CLIENT_TYPE=""
CENTRALE_ID=""
OUTPUT_FILE=""
EXECUTABLE="./c-wire"
TMP_DIR="./tmp"
GRAPHS_DIR="./graphs"

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
    mkdir -p "$TMP_DIR" "$GRAPHS_DIR" "./tests"
    rm -rf "$TMP_DIR/*"
}

function compiler_programme() {
    echo "Compilation du programme C..."
    if [[ ! -f "$EXECUTABLE" ]]; then
        gcc -o c-wire c-wire3.c
        if [[ $? -ne 0 ]]; then
            echo "Erreur lors de la compilation du programme C."
            exit 1
        fi
    else
        echo "Programme C déjà compilé."
    fi
}

function executer_programme() {
    echo "Exécution du programme avec les paramètres :"
    echo "  Fichier d'entrée : $INPUT_FILE"
    echo "  Type de station : $STATION_TYPE"
    echo "  Type de client : $CLIENT_TYPE"
    [[ -n "$CENTRALE_ID" ]] && echo "  ID Centrale : $CENTRALE_ID"

    # Définir les noms de fichiers de sortie pour chaque station/type de client
    OUTPUT_FILE="./tests/${STATION_TYPE}_${CLIENT_TYPE}.csv"
    [[ -n "$CENTRALE_ID" ]] && OUTPUT_FILE="${OUTPUT_FILE}_${CENTRALE_ID}.csv"

    if [[ "$STATION_TYPE" == "lv" && "$CLIENT_TYPE" == "all" ]]; then
        EXTRA_OUTPUT_FILE="./tests/lv_all_minmax.csv"
    fi

    # Exécution du programme C
    START_TIME=$(date +%s.%N)
    ./c-wire "$INPUT_FILE" "$STATION_TYPE" "$CLIENT_TYPE" "$OUTPUT_FILE" "$CENTRALE_ID"
    END_TIME=$(date +%s.%N)
    DURATION=$(echo "$END_TIME - $START_TIME" | bc)

    if [[ $? -ne 0 ]]; then
        echo "Erreur lors de l'exécution du programme C."
        exit 1
    fi

    echo "Traitement terminé en $DURATION secondes."
    echo "Fichier de sortie : $OUTPUT_FILE"

    if [[ "$STATION_TYPE" == "lv" && "$CLIENT_TYPE" == "all" ]]; then
        echo "Fichier supplémentaire : $EXTRA_OUTPUT_FILE"
    fi
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

