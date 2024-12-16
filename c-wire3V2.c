#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE 256

// --- Définition des structures ---
typedef struct {
    char id[20];           // Identifiant de la station
    char parentId[20];     // Identifiant de la station parente
    long capacity;         // Capacité de la station (kWh)
    long consumption;      // Consommation totale (kWh)
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

AVLNode *rotateRight(AVLNode *y) {
    AVLNode *x = y->left;
    AVLNode *T = x->right;

    x->right = y;
    y->left = T;

    y->height = max(height(y->left), height(y->right)) + 1;
    x->height = max(height(x->left), height(x->right)) + 1;

    return x;
}

AVLNode *rotateLeft(AVLNode *x) {
    AVLNode *y = x->right;
    AVLNode *T = y->left;

    y->left = x;
    x->right = T;

    x->height = max(height(x->left), height(x->right)) + 1;
    y->height = max(height(y->left), height(y->right)) + 1;

    return y;
}

AVLNode *insertNode(AVLNode *node, Station station) {
    if (!node) {
        return createNode(station);
    }

    if (strcmp(station.id, node->station.id) < 0) {
        node->left = insertNode(node->left, station);
    } else if (strcmp(station.id, node->station.id) > 0) {
        node->right = insertNode(node->right, station);
    } else {
        // Mise à jour des données si la station existe déjà
        node->station.capacity += station.capacity;
        node->station.consumption += station.consumption;
        return node;
    }

    node->height = 1 + max(height(node->left), height(node->right));
    int balance = height(node->left) - height(node->right);

    if (balance > 1 && strcmp(station.id, node->station.id) < 0) {
        return rotateRight(node);
    }

    if (balance < -1 && strcmp(station.id, node->station.id) > 0) {
        return rotateLeft(node);
    }

    if (balance > 1 && strcmp(station.id, node->station.id) > 0) {
        node->left = rotateLeft(node->left);
        return rotateRight(node);
    }

    if (balance < -1 && strcmp(station.id, node->station.id) < 0) {
        node->right = rotateRight(node->right);
        return rotateLeft(node);
    }

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

    // Ignorer la première ligne (en-tête)
    fgets(line, sizeof(line), file);

    while (fgets(line, sizeof(line), file)) {
        Station station = {0};
        char capacityStr[20], loadStr[20];

        // Lire chaque champ séparé par ;
        sscanf(line, "%[^;];%[^;];%*[^;];%*[^;];%*[^;];%*[^;];%[^;];%[^\n]",
               station.id, station.parentId, capacityStr, loadStr);

        station.capacity = (*capacityStr != '-') ? atol(capacityStr) : 0;
        station.consumption = (*loadStr != '-') ? atol(loadStr) : 0;

        // Vérification des données avant insertion
        if (strlen(station.id) > 0 && (station.capacity > 0 || station.consumption > 0)) {
            root = insertNode(root, station);
        }
    }

    fclose(file);
    return root;
}

// --- Filtrage et écriture des données ---
void filterAndSum(AVLNode *node, FILE *output, const char *type, const char *clientType) {
    if (!node) return;

    filterAndSum(node->left, output, type, clientType);

    // Conditions pour filtrer selon le type et le client
    int isHV_B = strcmp(type, "hvb") == 0;
    int isHV_A = strcmp(type, "hva") == 0;
    int isLV = strcmp(type, "lv") == 0;

    int isComp = strcmp(clientType, "comp") == 0;

    if (isHV_B && isComp) {
        fprintf(output, "%s:%ld:%ld\n", node->station.id, node->station.capacity, node->station.consumption);
    }

    filterAndSum(node->right, output, type, clientType);
}

// --- Libération de la mémoire ---
void freeAVL(AVLNode *node) {
    if (node) {
        freeAVL(node->left);
        freeAVL(node->right);
        free(node);
    }
}

// --- Fonction principale ---
int main(int argc, char *argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Utilisation : %s <fichier_csv> <type_station> <type_client> <fichier_sortie>\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *inputFile = argv[1];
    const char *stationType = argv[2];
    const char *clientType = argv[3];
    const char *outputFile = argv[4];

    AVLNode *root = parseCSV(inputFile);

    FILE *output = fopen(outputFile, "w");
    if (!output) {
        perror("Erreur d'ouverture du fichier de sortie");
        freeAVL(root);
        return EXIT_FAILURE;
    }

    fprintf(output, "ID:Capacity:Consumption\n");
    filterAndSum(root, output, stationType, clientType);

    fclose(output);
    freeAVL(root);
    printf("Fichier généré : %s\n", outputFile);

    return EXIT_SUCCESS;
}
