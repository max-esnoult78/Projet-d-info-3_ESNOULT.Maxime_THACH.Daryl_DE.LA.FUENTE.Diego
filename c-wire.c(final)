#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define MAX_LIGNE 256

// --- Définition des structures ---
typedef struct {
    char id[20];           // Identifiant de la station
    char hvb[20];          // Identifiant de la station HV-B
    char hva[20];          // Identifiant de la station HV-A
    char lv[20];           // Identifiant de la station LV
    char entreprise[20];   // Identifiant d'une entreprise (consommateur)
    char particulier[20];  // Identifiant d'un particulier (consommateur)
    long capacite;         // Capacité maximale de transfert ou de production (en kWh)
    long consommation;     // Consommation totale de la station (en kWh)
} Station;

typedef struct NoeudAVL {
    Station station;         // Les données associées au nœud AVL
    struct NoeudAVL *gauche; // Fils gauche
    struct NoeudAVL *droite; // Fils droit
    int hauteur;             // Hauteur du nœud
} NoeudAVL;

// --- Fonctions AVL ---
int hauteur(NoeudAVL *noeud) {
    // Retourne la hauteur d'un nœud, ou 0 si le nœud est NULL.
    return noeud ? noeud->hauteur : 0;
}

int max(int a, int b) {
    // Retourne le maximum entre deux entiers.
    return (a > b) ? a : b;
}

NoeudAVL *creerNoeud(Station station) {
    // Ici, nous créons un nouveau nœud AVL contenant les informations d'une station.
    NoeudAVL *noeud = (NoeudAVL *)malloc(sizeof(NoeudAVL));
    if (!noeud) {
        perror("Erreur d'allocation mémoire");
        exit(EXIT_FAILURE);
    }
    noeud->station = station;
    noeud->gauche = noeud->droite = NULL;
    noeud->hauteur = 1; // Un nouveau nœud a une hauteur de 1.
    return noeud;
}

NoeudAVL *rotationDroite(NoeudAVL *y) {
    // Cette fonction effectue une rotation à droite pour équilibrer un nœud déséquilibré.
    NoeudAVL *x = y->gauche;
    NoeudAVL *T = x->droite;

    // Effectue la rotation
    x->droite = y;
    y->gauche = T;

    // Met à jour les hauteurs
    y->hauteur = max(hauteur(y->gauche), hauteur(y->droite)) + 1;
    x->hauteur = max(hauteur(x->gauche), hauteur(x->droite)) + 1;

    // Retourne le nouveau nœud racine
    return x;
}

NoeudAVL *rotationGauche(NoeudAVL *x) {
    // Cette fonction effectue une rotation à gauche pour équilibrer un nœud déséquilibré.
    NoeudAVL *y = x->droite;
    NoeudAVL *T = y->gauche;

    // Effectue la rotation
    y->gauche = x;
    x->droite = T;

    // Met à jour les hauteurs
    x->hauteur = max(hauteur(x->gauche), hauteur(x->droite)) + 1;
    y->hauteur = max(hauteur(y->gauche), hauteur(y->droite)) + 1;

    // Retourne le nouveau nœud racine
    return y;
}

NoeudAVL *insererNoeud(NoeudAVL *noeud, Station station) {
    // Cette fonction insère une station dans l'arbre AVL de manière ordonnée.

    if (!noeud) return creerNoeud(station);

    // On génère une clé unique basée sur les champs de la station pour comparer les nœuds
    char cleNoeud[100], cleStation[100];
    snprintf(cleNoeud, sizeof(cleNoeud), "%19s_%19s_%19s_%19s_%19s_%19s",
             noeud->station.id, noeud->station.hvb, noeud->station.hva,
             noeud->station.lv, noeud->station.entreprise, noeud->station.particulier);

    snprintf(cleStation, sizeof(cleStation), "%19s_%19s_%19s_%19s_%19s_%19s",
             station.id, station.hvb, station.hva,
             station.lv, station.entreprise, station.particulier);

    // Compare les clés pour décider où insérer la station
    int cmp = strcmp(cleStation, cleNoeud);
    if (cmp < 0) {
        noeud->gauche = insererNoeud(noeud->gauche, station);
    } else if (cmp > 0) {
        noeud->droite = insererNoeud(noeud->droite, station);
    }

    // Mise à jour de la hauteur et équilibrage du nœud
    noeud->hauteur = 1 + max(hauteur(noeud->gauche), hauteur(noeud->droite));

    int balance = hauteur(noeud->gauche) - hauteur(noeud->droite);

    // Effectue des rotations en cas de déséquilibre
    if (balance > 1 && cmp < 0) return rotationDroite(noeud);
    if (balance < -1 && cmp > 0) return rotationGauche(noeud);
    if (balance > 1 && cmp > 0) {
        noeud->gauche = rotationGauche(noeud->gauche);
        return rotationDroite(noeud);
    }
    if (balance < -1 && cmp < 0) {
        noeud->droite = rotationDroite(noeud->droite);
        return rotationGauche(noeud);
    }

    return noeud;
}

// Lecture du fichier CSV
NoeudAVL *lireCSV(const char *fichier) {
    // Cette fonction lit un fichier CSV et construit un arbre AVL à partir des données.
    FILE *file = fopen(fichier, "r");
    if (!file) {
        perror("Erreur d'ouverture du fichier CSV");
        exit(EXIT_FAILURE);
    }

    NoeudAVL *racine = NULL;
    char ligne[MAX_LIGNE];

    fgets(ligne, sizeof(ligne), file); // Ignore l'en-tête

    while (fgets(ligne, sizeof(ligne), file)) {
        Station station = {0};
        char capaciteStr[20] = "", consommationStr[20] = "";

        // analyser chaque ligne du fichier CSV pour en extraire les données pertinentes.
        if (sscanf(ligne, "%19[^;];%19[^;];%19[^;];%19[^;];%19[^;];%19[^;];%19[^;];%19[^\n]",
                   station.id, station.hvb, station.hva, station.lv,
                   station.entreprise, station.particulier, capaciteStr, consommationStr) == 8) {
            station.capacite = (*capaciteStr != '-') ? atol(capaciteStr) : 0;
            station.consommation = (*consommationStr != '-') ? atol(consommationStr) : 0;

            if (station.capacite > 0 || station.consommation > 0) {
                racine = insererNoeud(racine, station);
            }
        }
    }

    fclose(file);
    return racine;
}

// Écriture des données filtrées dans un fichier de sortie
void filtrerEtEcrire(NoeudAVL *noeud, FILE *sortie, const char *type, const char *client) {
    if (!noeud) return;

    // Traite le sous-arbre gauche
    filtrerEtEcrire(noeud->gauche, sortie, type, client);

    // Vérifie si le nœud correspond aux critères
    int correspondType = 0, correspondClient = 0;

    if (strcmp(type, "hvb") == 0 && strcmp(noeud->station.hvb, "-") != 0) correspondType = 1;
    if (strcmp(type, "hva") == 0 && strcmp(noeud->station.hva, "-") != 0) correspondType = 1;
    if (strcmp(type, "lv") == 0 && strcmp(noeud->station.lv, "-") != 0) correspondType = 1;

    if ((strcmp(client, "comp") == 0 && noeud->station.capacite > 0) ||
        (strcmp(client, "indiv") == 0 && noeud->station.consommation > 0) ||
        (strcmp(client, "all") == 0)) correspondClient = 1;

    // Écrit dans le fichier si les critères sont remplis
    if (correspondType && correspondClient) {
        fprintf(sortie, "%s:%ld:%ld\n", noeud->station.id, noeud->station.capacite, noeud->station.consommation);
    }

    // Traite le sous-arbre droit
    filtrerEtEcrire(noeud->droite, sortie, type, client);
}

// Fonction principale
int main(int argc, char *argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Utilisation : %s <fichier_csv> <type_station> <type_client> <fichier_sortie>\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *fichierEntree = argv[1];
    const char *typeStation = argv[2];
    const char *typeClient = argv[3];
    const char *fichierSortie = argv[4];

    clock_t debut = clock(); // Démarre le chronométrage

    NoeudAVL *racine = lireCSV(fichierEntree);

    FILE *sortie = fopen(fichierSortie, "w");
    if (!sortie) {
        perror("Erreur d'ouverture du fichier de sortie");
        return EXIT_FAILURE;
    }

    fprintf(sortie, "ID:Capacité:Consommation\n");
    filtrerEtEcrire(racine, sortie, typeStation, typeClient);

    fclose(sortie);

    clock_t fin = clock(); // Arrête le chronométrage
    double tempsEcoule = (double)(fin - debut) / CLOCKS_PER_SEC;

    printf("Fichier généré : %s\n", fichierSortie);
    printf("Temps d'exécution : %.2f secondes\n", tempsEcoule);

    return EXIT_SUCCESS;
}
