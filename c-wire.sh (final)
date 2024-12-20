#!/bin/bash

# --- Variables ---
INPUT_FILE="$1"
EXECUTABLE="./c-wire"
OUTPUT_DIR="./output"

# --- Fonction d'aide ---
function afficher_aide() {
    echo "Utilisation : $0 <fichier_csv>"
    echo "Exemple : $0 c-wire_v25.dat"
    exit 1
}

# --- Vérification des arguments ---
if [[ $# -lt 1 ]]; then
    afficher_aide
fi

# --- Préparation des dossiers ---
mkdir -p "$OUTPUT_DIR"

# --- Compilation du programme C ---
if [[ ! -f "$EXECUTABLE" ]]; then
    echo "Compilation du programme C..."
    gcc -o c-wire c-wire.c
    if [[ $? -ne 0 ]]; then
        echo "Erreur : Échec de la compilation."
        exit 1
    fi
else
    echo "Programme C déjà compilé."
fi

# --- Exécution avec les différentes combinaisons ---
echo "Début de la génération des fichiers..."

declare -A combinaisons=(
    ["hvb_comp"]="hvb comp"
    ["hva_comp"]="hva comp"
    ["lv_comp"]="lv comp"
    ["lv_indiv"]="lv indiv"
    ["lv_all"]="lv all"
)

for key in "${!combinaisons[@]}"; do
    stationType=$(echo "${combinaisons[$key]}" | cut -d' ' -f1)
    clientType=$(echo "${combinaisons[$key]}" | cut -d' ' -f2)
    outputFile="${OUTPUT_DIR}/${key}.csv"

    echo "Lancement : $EXECUTABLE $INPUT_FILE $stationType $clientType $outputFile"
    $EXECUTABLE "$INPUT_FILE" "$stationType" "$clientType" "$outputFile"

    if [[ $? -ne 0 ]]; then
        echo "Erreur : Exécution échouée pour $stationType $clientType."
        exit 1
    fi
done

echo "Tous les fichiers ont été générés dans le dossier $OUTPUT_DIR."
