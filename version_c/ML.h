#ifndef ML_H
#define ML_H
#include "list.h"

#define true 1
#define false 0

typedef int bool;

typedef struct 
{
    int* positions;
    int length;
} list_positions; //Estrutura de dados auxiliar

double calc_dist(double* x_train, double* x_test, int w); //Calcula distância euclidiana

bool isHere(int i, list_positions* list); //Verifica se o vizinho foi escolhido

Node* getInit(int i, LIST_DATA* list); //Devolve o dado

bool split_data(LIST_DATA* data, double*** x, double** y, int* lines, int w, int h); //Divide o conjunto de treino e teste conforme w e h

double* knn(double** x_train, double* y_train, double** x_test, int lines_train, int lines_test, int w, int k); //Realiza o algoritmo knn

#endif