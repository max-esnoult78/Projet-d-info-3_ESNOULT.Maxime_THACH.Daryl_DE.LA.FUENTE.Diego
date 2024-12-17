#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h> // Pour isspace

#define MAX_LINE 256

// --- Structure pour les stations ---
typedef struct {
    char id[20];
    char hvb[5];
    char hva[5];
    char lv[5];
    char comp[5];
    char indiv[5];
    long capacity;
    long consumption;
} Station;

typedef struct AVLNode {
    Station station;
    struct AVLNode *left;
    struct AVLNode *right;
    int height;
} AVLNode;

// --- Fonctions AVL ---
int height(AVLNode *node) {
    return node ? node->height : 0;
}

int max(int a, int b) {
    return (a > b) ? a : b;
}

AVLNode *createNode(Station station) {
    AVLNode *node = (AVLNode *)malloc(sizeof(AVLNode));
    if (!node) {
        perror("Erreur d'allocation mémoire");
        exit(EXIT_FAILURE);
    }
    node->station = station;
    node->left = node->right = NULL;
    node->height = 1;
    return node;
}

AVLNode *insertNode(AVLNode *node, Station station) {
    if (!node) return createNode(station);

    // Créer une comparaison basée uniquement sur l'ordre d'insertion
    if (node->station.capacity < station.capacity || 
        (node->station.capacity == station.capacity && node->station.consumption < station.consumption)) {
        node->left = insertNode(node->left, station);
    } else {
        node->right = insertNode(node->right, station);
    }

    node->height = 1 + max(height(node->left), height(node->right));
    return node;
}



// --- Lecture du fichier CSV ---
AVLNode *parseCSV(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Erreur d'ouverture du fichier CSV");
        exit(EXIT_FAILURE);
    }

    AVLNode *root = NULL;
    char line[MAX_LINE];

    fgets(line, sizeof(line), file); // Ignore l'en-tête
    while (fgets(line, sizeof(line), file)) {
        Station s = {0};
        char capacityStr[20], consumptionStr[20];

        sscanf(line, "%[^;];%[^;];%[^;];%[^;];%[^;];%[^;];%[^;];%[^\n]",
               s.id, s.hvb, s.hva, s.lv, s.comp, s.indiv, capacityStr, consumptionStr);

        s.capacity = (*capacityStr != '-') ? atol(capacityStr) : 0;
        s.consumption = (*consumptionStr != '-') ? atol(consumptionStr) : 0;

        if (s.capacity > 0 || s.consumption > 0) {
            root = insertNode(root, s);
        }
    }

    fclose(file);
    return root;
}

// --- Fonction pour vérifier un champ valide ---
int isValidField(const char *field) {
    if (field == NULL) return 0;
    while (*field) {
        if (!isspace((unsigned char)*field) && *field != '-') return 1;
        field++;
    }
    return 0;
}

// --- Filtrage et écriture des données ---
void filterAndWrite(AVLNode *node, FILE *output, const char *type, const char *client) {
    if (!node) return;

    filterAndWrite(node->left, output, type, client);

    // Vérifier si Capacity ou Consumption est positif
    if (node->station.capacity > 0 || node->station.consumption > 0) {
        fprintf(output, "%s:%ld:%ld\n", node->station.id, node->station.capacity, node->station.consumption);
        printf("Écriture : ID=%s, CAPACITY=%ld, CONSUMPTION=%ld\n",
               node->station.id, node->station.capacity, node->station.consumption);
    }

    filterAndWrite(node->right, output, type, client);
}



// --- Fonction principale ---
int main(int argc, char *argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Utilisation : %s <fichier_csv> <type_station> <type_client> <fichier_sortie>\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *inputFile = argv[1];
    const char *type = argv[2];
    const char *client = argv[3];
    const char *outputFile = argv[4];

    AVLNode *root = parseCSV(inputFile);

    FILE *output = fopen(outputFile, "w");
    if (!output) {
        perror("Erreur d'ouverture du fichier de sortie");
        return EXIT_FAILURE;
    }

    fprintf(output, "ID:Capacity:Consumption\n");
    filterAndWrite(root, output, type, client);

    fclose(output);
    printf("Fichier généré : %s\n", outputFile);

    return EXIT_SUCCESS;
}
