#include "list.h"


#define true 1
#define false 0

typedef int bool;

bool split_data(LIST_DATA* data, double** x, double* y, int w, int h); //Divide o conjunto de treino e teste conforme w e h

double* knn(double** x_train, double* y_train, double** x_test, int lines_train, int lines_test, int w, int k); //Realiza o algoritmo knn