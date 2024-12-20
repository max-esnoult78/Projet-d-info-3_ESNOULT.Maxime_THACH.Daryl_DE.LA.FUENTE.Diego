Étapes d’utilisation: 



1. Préparation de l’environnement

    Clonez ou copiez les fichiers nécessaires dans un répertoire de travail.
    Placez le fichier CSV d’entrée (c-wire_v25.dat) dans le répertoire Input/.

2. Compilation du programme C

    Naviguez dans le répertoire du projet :

cd /chemin/vers/c-wire

Compilez le programme à l’aide du Makefile :

    make

    Cela génère un exécutable appelé c-wire.

3. Utilisation du script shell

Le script c-wire3.sh simplifie l’exécution du programme. Il nettoie les répertoires, compile le programme et exécute le programme C avec les arguments fournis.
Syntaxe de la commande:   

./c-wire3.sh <fichier_données> <type_station> <type_client> [ID_station]

    <fichier_données> : Nom du fichier CSV d’entrée (doit être dans le dossier Input/).
    <type_station> : Type de station (hvb, hva, lv).
    <type_client> : Type de client (comp, indiv, all).
    [ID_station] : (Optionnel) ID d’une station spécifique (entre 1 et 5). Si absent, toutes les stations sont traitées.

4. Exemples d’exécution
Traitement de toutes les stations LV avec tous les clients :

./c-wire3.sh c-wire_v25.dat lv all

Traitement des stations HVB avec uniquement les entreprises :

./c-wire3.sh c-wire_v25.dat hvb comp

Traitement de la station LV ID 3 avec les particuliers uniquement :

./c-wire3.sh c-wire_v25.dat lv indiv 3

5. Résultats

    Les fichiers générés sont sauvegardés dans le répertoire tests/.
    Le temps d’exécution pour chaque fichier généré est affiché dans le terminal.

6. Nettoyage des fichiers générés
Pour supprimer les fichiers objets et l’exécutable :

make clean

Pour une suppression complète :

make fclean

THACH Daryl, ESNOULT Maximme, DE LA FUENTE Diego
Projet C-Wire - Année 2024
