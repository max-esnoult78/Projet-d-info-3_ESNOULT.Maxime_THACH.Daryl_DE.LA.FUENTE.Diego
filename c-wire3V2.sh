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
TESTS_DIR="./tests"

# --- Fonctions ---
afficher_aide() {
    echo "Utilisation : $0 <fichier_csv> <type_station> <type_client> [id_centrale]"
    echo "  - fichier_csv : chemin du fichier d'entrée."
    echo "  - type_station : hvb, hva, lv."
    echo "  - type_client : comp, indiv, all."
    echo "  - id_centrale : (optionnel) identifiant d'une centrale spécifique."
    echo "Options supplémentaires :"
    echo "  -h : Afficher cette aide."
    exit 0
}

verifier_arguments() {
    if [[ "$1" == "-h" ]]; then
        afficher_aide
    fi

    if [[ -z "$INPUT_FILE" || -z "$STATION_TYPE" || -z "$CLIENT_TYPE" ]]; then
        echo "Erreur : Paramètres manquants. Veuillez les définir via le menu."
        return 1
    fi

    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "Erreur : Fichier d'entrée introuvable."
        return 1
    fi

    if [[ "$STATION_TYPE" != "hvb" && "$STATION_TYPE" != "hva" && "$STATION_TYPE" != "lv" ]]; then
        echo "Erreur : Type de station invalide. Options : hvb, hva, lv."
        return 1
    fi

    if [[ "$CLIENT_TYPE" != "comp" && "$CLIENT_TYPE" != "indiv" && "$CLIENT_TYPE" != "all" ]]; then
        echo "Erreur : Type de client invalide. Options : comp, indiv, all."
        return 1
    fi

    return 0
}

preparer_dossiers() {
    mkdir -p "$TMP_DIR" "$GRAPHS_DIR" "$TESTS_DIR"
    rm -rf "$TMP_DIR"/*
    echo "Dossiers préparés."
}

compiler_programme() {
    echo "Compilation du programme C..."
    if [[ ! -f "$EXECUTABLE" ]]; then
        gcc -Wall -Wextra -O2 -o c-wire c-wire.c
        if [[ $? -ne 0 ]]; then
            echo "Erreur : La compilation du programme C a échoué."
            exit 1
        fi
    else
        echo "Programme C déjà compilé."
    fi
}

executer_programme() {
    verifier_arguments
    if [[ $? -ne 0 ]]; then
        echo "Erreur : Vérification des arguments échouée."
        return 1
    fi

    echo "Exécution du programme avec les paramètres suivants :"
    echo "  Fichier : $INPUT_FILE"
    echo "  Type de station : $STATION_TYPE"
    echo "  Type de client : $CLIENT_TYPE"
    [[ -n "$CENTRALE_ID" ]] && echo "  ID Centrale : $CENTRALE_ID"

    # Définir le fichier de sortie
    OUTPUT_FILE="${TESTS_DIR}/${STATION_TYPE}_${CLIENT_TYPE}.csv"
    [[ -n "$CENTRALE_ID" ]] && OUTPUT_FILE="${TESTS_DIR}/${STATION_TYPE}_${CLIENT_TYPE}_${CENTRALE_ID}.csv"

    # Appeler le programme C
    ./c-wire "$INPUT_FILE" "$STATION_TYPE" "$CLIENT_TYPE" "$OUTPUT_FILE" "$CENTRALE_ID"
    if [[ $? -ne 0 ]]; then
        echo "Erreur : Le programme C a rencontré un problème."
        return 1
    fi

    echo "Traitement terminé. Fichier de sortie : $OUTPUT_FILE"
}

# --- Menu Principal ---
while true; do
    echo "=== Menu Principal ==="
    echo "1. Sélectionner le fichier CSV"
    echo "2. Choisir le type de station (hvb, hva, lv)"
    echo "3. Choisir le type de client (comp, indiv, all)"
    echo "4. Spécifier un identifiant de centrale (optionnel)"
    echo "5. Lancer le traitement"
    echo "6. Quitter"
    echo "======================="
    read -p "Choisissez une option : " choix

    case $choix in
        1)
            read -p "Entrez le chemin du fichier CSV : " INPUT_FILE
            if [[ ! -f "$INPUT_FILE" ]]; then
                echo "Erreur : Fichier introuvable."
                INPUT_FILE=""
            else
                echo "Fichier sélectionné : $INPUT_FILE"
            fi
            ;;
        2)
            read -p "Entrez le type de station (hvb, hva, lv) : " STATION_TYPE
            ;;
        3)
            read -p "Entrez le type de client (comp, indiv, all) : " CLIENT_TYPE
            ;;
        4)
            read -p "Entrez l'identifiant de la centrale (laisser vide si non applicable) : " CENTRALE_ID
            ;;
        5)
            preparer_dossiers
            compiler_programme
            executer_programme
            ;;
        6)
            echo "Au revoir !"
            exit 0
            ;;
        *)
            echo "Option invalide, veuillez réessayer."
            ;;
    esac
done
