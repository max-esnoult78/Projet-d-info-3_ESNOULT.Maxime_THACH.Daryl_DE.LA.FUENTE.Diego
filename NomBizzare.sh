#!/bin/bash

# Vérifier les arguments
if [ "$#" -ne 1 ]; then
    echo "Utilisation : $0 <fichier_csv>"
    exit 1
fi

# Variables
input_file="$1"
output_file="resultats.csv"
program_name="./c-wire"

# Compilation
echo "Compilation du programme C..."
gcc -o c-wire c-wire.c

# Vérification si la compilation a réussi
if [ $? -ne 0 ]; then
    echo "Erreur lors de la compilation. Vérifiez votre fichier C."
    exit 1
fi

# Demander les paramètres d'observation
echo "Sélectionnez le type de station :"
echo "1) hvb (High Voltage B)"
echo "2) hva (High Voltage A)"
echo "3) lv (Low Voltage)"
read -p "Votre choix (1-3) : " station_choice

case $station_choice in
    1) station_type="hvb" ;;
    2) station_type="hva" ;;
    3) station_type="lv" ;;
    *) echo "Choix invalide. Arrêt du script." ; exit 1 ;;
esac

echo "Sélectionnez le type de client :"
echo "1) comp (entreprises uniquement)"
echo "2) indiv (particuliers uniquement)"
echo "3) all (tous)"
read -p "Votre choix (1-3) : " client_choice

case $client_choice in
    1) client_type="comp" ;;
    2) client_type="indiv" ;;
    3) client_type="all" ;;
    *) echo "Choix invalide. Arrêt du script." ; exit 1 ;;
esac

# Exécution
echo "Exécution du programme avec les données CSV..."
$program_name "$input_file" "$station_type" "$client_type" "$output_file"

# Vérification si l'exécution a réussi
if [ $? -ne 0 ]; then
    echo "Erreur lors de l'exécution du programme."
    exit 1
fi

echo "Résultats exportés dans $output_file"
