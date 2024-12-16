#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// --- Structures ---
typedef struct {
    char id[20];
    char parentId[20];
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

void inOrderTraversal(AVLNode *node, FILE *output) {
    if (!node) return;

    inOrderTraversal(node->left, output);
    fprintf(output, "%s:%ld:%ld\n", node->station.id, node->station.capacity, node->station.consumption);
    inOrderTraversal(node->right, output);
}

void freeTree(AVLNode *root) {
    if (!root) return;
    freeTree(root->left);
    freeTree(root->right);
    free(root);
}

// --- Lecture du fichier ---
AVLNode *parseDataFile(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Erreur d'ouverture du fichier");
        exit(EXIT_FAILURE);
    }

    AVLNode *root = NULL;
    char line[256];

    while (fgets(line, sizeof(line), file)) {
        Station station = {0};
        char capacityStr[20], loadStr[20];

        // Adapter le parsing en fonction du format
        sscanf(line, "%[^;];%[^;];%[^;];%[^\n]",
               station.id, station.parentId, capacityStr, loadStr);

        station.capacity = (*capacityStr != '-') ? atol(capacityStr) : 0;
        station.consumption = (*loadStr != '-') ? atol(loadStr) : 0;

        if (strlen(station.id) > 0) {
            root = insertNode(root, station);
        }
    }

    fclose(file);
    return root;
}

// --- Main ---
int main(int argc, char *argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Usage: %s <data_file> <station_type> <client_type> <output_file>\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *inputFile = argv[1];
    const char *outputFile = argv[4];

    AVLNode *root = parseDataFile(inputFile);

    FILE *output = fopen(outputFile, "w");
    if (!output) {
        perror("Erreur d'ouverture du fichier de sortie");
        return EXIT_FAILURE;
    }

    fprintf(output, "ID:Capacity:Consumption\n");
    inOrderTraversal(root, output);

    fclose(output);
    freeTree(root);
    printf("Fichier généré : %s\n", outputFile);

    return EXIT_SUCCESS;
}
