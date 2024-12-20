Étapes d’utilisation: 



1. Préparation de l’environnement

    Clonez ou copiez les fichiers nécessaires dans un répertoire de travail.
    Placez le fichier CSV d’entrée (c-wire_v25.dat) dans le répertoire Input/.

2. Compilation du programme C

    Naviguez dans le répertoire du projet :

cd /chemin/vers/c-wire

    
3. Utilisation du script shell

Le script c-wire3.sh simplifie l’exécution du programme. Il nettoie les répertoires, compile le programme et exécute le programme C avec les arguments fournis.
Syntaxe de la commande:   

chmod +x c-wire.sh

./c-wire.sh <fichier_données> 

4. Exemples d’exécution ( Le programme crée tous les fichiers)

./c-wire.sh c-wire_v25.dat 


5. Résultats

    Les fichiers générés sont sauvegardés dans le répertoire output/.
    Le temps d’exécution pour chaque fichier généré est affiché dans le terminal.


THACH Daryl, ESNOULT Maximme, DE LA FUENTE Diego
Projet C-Wire - Année 2024
