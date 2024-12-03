#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TOP_N 10

// --- Définition des structures ---
typedef struct {
    char id[10];          // Identifiant de la station
    char parentId[10];    // Identifiant de la station parente
    long capacity;        // Capacité de transfert (kWh)
    long consumption;     // Consommation totale (kWh)
    int isCompany;        // Indique si la consommation vient d'une entreprise (1) ou d'un particulier (0)
} Station;

typedef struct NodeAVL {
    Station station;          // Données de la station
    struct NodeAVL *left;     // Sous-arbre gauche
    struct NodeAVL *right;    // Sous-arbre droit
    int height;               // Hauteur du nœud
} NodeAVL;

// --- Fonctions AVL ---
int height(NodeAVL *node) {
    return node ? node->height : 0;
}

int max(int a, int b) {
    return (a > b) ? a : b;
}

NodeAVL *createNode(Station station) {
    NodeAVL *node = (NodeAVL *)malloc(sizeof(NodeAVL));
    node->station = station;
    node->left = NULL;
    node->right = NULL;
    node->height = 1;
    return node;
}

NodeAVL *rotateRight(NodeAVL *y) {
    NodeAVL *x = y->left;
    NodeAVL *T = x->right;

    x->right = y;
    y->left = T;

    y->height = max(height(y->left), height(y->right)) + 1;
    x->height = max(height(x->left), height(x->right)) + 1;

    return x;
}

NodeAVL *rotateLeft(NodeAVL *x) {
    NodeAVL *y = x->right;
    NodeAVL *T = y->left;

    y->left = x;
    x->right = T;

    x->height = max(height(x->left), height(x->right)) + 1;
    y->height = max(height(y->left), height(y->right)) + 1;

    return y;
}

NodeAVL *insertNode(NodeAVL *node, Station station) {
    if (!node) {
        return createNode(station);
    }

    if (strcmp(station.id, node->station.id) < 0) {
        node->left = insertNode(node->left, station);
    } else if (strcmp(station.id, node->station.id) > 0) {
        node->right = insertNode(node->right, station);
    } else {
        // Mise à jour si la station existe déjà
        node->station.capacity += station.capacity;
        node->station.consumption += station.consumption;
        return node;
    }

    node->height = max(height(node->left), height(node->right)) + 1;

    int balance = height(node->left) - height(node->right);

    if (balance > 1 && strcmp(station.id, node->left->station.id) < 0) {
        return rotateRight(node);
    }

    if (balance < -1 && strcmp(station.id, node->right->station.id) > 0) {
        return rotateLeft(node);
    }

    if (balance > 1 && strcmp(station.id, node->left->station.id) > 0) {
        node->left = rotateLeft(node->left);
        return rotateRight(node);
    }

    if (balance < -1 && strcmp(station.id, node->right->station.id) < 0) {
        node->right = rotateRight(node->right);
        return rotateLeft(node);
    }

    return node;
}

// --- Filtrage et Calculs ---
void filterStations(NodeAVL *node, const char *stationType, const char *clientType, long *totalCapacity, long *totalConsumption, long *companyConsumption, long *individualConsumption) {
    if (!node) return;

    filterStations(node->left, stationType, clientType, totalCapacity, totalConsumption, companyConsumption, individualConsumption);

    if (strstr(node->station.id, stationType)) {
        if ((strcmp(clientType, "all") == 0) ||
            (strcmp(clientType, "comp") == 0 && node->station.isCompany) ||
            (strcmp(clientType, "indiv") == 0 && !node->station.isCompany)) {
            *totalCapacity += node->station.capacity;
            *totalConsumption += node->station.consumption;
            if (node->station.isCompany) {
                *companyConsumption += node->station.consumption;
            } else {
                *individualConsumption += node->station.consumption;
            }
        }
    }

    filterStations(node->right, stationType, clientType, totalCapacity, totalConsumption, companyConsumption, individualConsumption);
}

// --- Lecture d'un fichier CSV ---
NodeAVL *parseCSV(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Erreur lors de l'ouverture du fichier CSV");
        exit(EXIT_FAILURE);
    }

    NodeAVL *root = NULL;
    char line[256];

    while (fgets(line, sizeof(line), file)) {
        Station station;
        sscanf(line, "%[^;];%[^;];%ld;%ld;%d", station.id, station.parentId, &station.capacity, &station.consumption, &station.isCompany);

        root = insertNode(root, station);
    }

    fclose(file);
    return root;
}

// --- Fonction principale ---
int main(int argc, char *argv[]) {
    if (argc != 5) {
        printf("Utilisation : %s <fichier_csv> <station_type> <client_type> <fichier_sortie>\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *inputFile = argv[1];
    const char *stationType = argv[2];
    const char *clientType = argv[3];
    const char *outputFile = argv[4];

    NodeAVL *root = parseCSV(inputFile);

    long totalCapacity = 0, totalConsumption = 0, companyConsumption = 0, individualConsumption = 0;

    filterStations(root, stationType, clientType, &totalCapacity, &totalConsumption, &companyConsumption, &individualConsumption);

    FILE *file = fopen(outputFile, "w");
    if (!file) {
        perror("Erreur lors de la création du fichier CSV");
        return EXIT_FAILURE;
    }

    fprintf(file, "Total Capacity: %ld\n", totalCapacity);
    fprintf(file, "Total Consumption: %ld\n", totalConsumption);
    fprintf(file, "Company Consumption: %ld\n", companyConsumption);
    fprintf(file, "Individual Consumption: %ld\n", individualConsumption);

    fclose(file);

    printf("Fichier généré : %s\n", outputFile);
    return EXIT_SUCCESS;
}
