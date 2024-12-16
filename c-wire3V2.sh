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
function afficher_menu() {
    echo "=== Menu Principal ==="
    echo "1. Sélectionner le fichier CSV"
    echo "2. Choisir le type de station (hvb, hva, lv)"
    echo "3. Choisir le type de client (comp, indiv, all)"
    echo "4. Spécifier un identifiant de centrale (optionnel)"
    echo "5. Lancer le traitement"
    echo "6. Quitter"
    echo "======================="
}

function choisir_fichier() {
    read -p "Entrez le chemin du fichier CSV : " INPUT_FILE
    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "Erreur : Fichier introuvable."
        INPUT_FILE=""
    else
        echo "Fichier sélectionné : $INPUT_FILE"
    fi
}

function choisir_station() {
    echo "Types de station disponibles : hvb, hva, lv"
    read -p "Entrez le type de station : " STATION_TYPE
    if [[ "$STATION_TYPE" != "hvb" && "$STATION_TYPE" != "hva" && "$STATION_TYPE" != "lv" ]]; then
        echo "Erreur : Type de station invalide."
        STATION_TYPE=""
    else
        echo "Type de station sélectionné : $STATION_TYPE"
    fi
}

function choisir_client() {
    echo "Types de client disponibles : comp, indiv, all"
    read -p "Entrez le type de client : " CLIENT_TYPE
    if [[ "$CLIENT_TYPE" != "comp" && "$CLIENT_TYPE" != "indiv" && "$CLIENT_TYPE" != "all" ]]; then
        echo "Erreur : Type de client invalide."
        CLIENT_TYPE=""
    elif [[ ("$STATION_TYPE" == "hvb" || "$STATION_TYPE" == "hva") && "$CLIENT_TYPE" != "comp" ]]; then
        echo "Erreur : Pour HVB et HVA, seuls les clients 'comp' sont valides."
        CLIENT_TYPE=""
    else
        echo "Type de client sélectionné : $CLIENT_TYPE"
    fi
}

function specifier_centrale() {
    read -p "Entrez l'identifiant de la centrale (laisser vide si non applicable) : " CENTRALE_ID
    echo "ID Centrale sélectionné : $CENTRALE_ID"
}

function lancer_traitement() {
    if [[ -z "$INPUT_FILE" || -z "$STATION_TYPE" || -z "$CLIENT_TYPE" ]]; then
        echo "Erreur : Tous les paramètres obligatoires ne sont pas définis."
        return
    fi

    verifier_arguments "$INPUT_FILE" "$STATION_TYPE" "$CLIENT_TYPE" "$CENTRALE_ID"
    preparer_dossiers
    compiler_programme
    executer_programme
}

# --- Script Principal ---
while true; do
    afficher_menu
    read -p "Choisissez une option : " choix
    case $choix in
        1)
            choisir_fichier
            ;;
        2)
            choisir_station
            ;;
        3)
            choisir_client
            ;;
        4)
            specifier_centrale
            ;;
        5)
            lancer_traitement
            ;;
        6)
            echo "Quitter..."
            exit 0
            ;;
        *)
            echo "Option invalide."
            ;;
    esac
done
