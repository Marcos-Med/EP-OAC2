#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "../version_c/ML.h"
#include "../version_c/list.h"
#include "threads.h"

bool split_data(LIST_DATA* data, double*** x, double** y, int* lines_data, int w, int h){ //Treina o modelo
    bool flag = (!data) || (w == 0) || (h == 0);
    if(flag) return false;
    int lines = data->length - w - h + 1; //Número de linhas
    (*lines_data) = lines;
    (*x) = (double**) malloc(lines*sizeof(double*));
    (*y) = (double*) malloc(lines*sizeof(double));
    for(int i = 0; i < lines; i++){
        (*x)[i] = (double*) malloc(w*sizeof(double));
    }
    #pragma omp parallel for num_threads(NUM_THREADS)
    for(int i = 0; i < lines; i++){
        Node* node = getInit(i, data); //Busca o ínicio da linha da matriz X
        for(int j = 0; j < w; j++){ //Gera a matriz X
            (*x)[i][j] = node->value;
            node = node->next;
        }
        int posY = i + w + h - 1; //Dia da previsão y[i]
        node = getInit(posY, data); //Busca a previsão
        (*y)[i] = node->value;
    }
    return true;
}

Node* getInit(int i, LIST_DATA* list){ //Encontra o dado inicial
    Node* node = list->head;
    int j = 0;
    while(j != i){ //Enquanto não for igual ao início
        node = node->next;
        j++;
    }
    return node;
}

double* knn(double** x_train, double* y_train, double** x_test, int lines_train, int lines_test, int w, int k){ //Realiza a regressão
    double* result = (double*) malloc(lines_test*sizeof(double)); //y_pred
    #pragma omp parallel for num_threads(NUM_THREADS)
    for(int i = 0; i < lines_test; i++){
        double* dist = (double*) malloc(lines_train * sizeof(double)); //vetor de distância
        list_positions* list = (list_positions*) malloc(sizeof(list_positions)); //estrutura de dados auxiliar
        list->length = 0;
        list->positions = (int*) malloc(sizeof(int) * k);
        #pragma omp parallel for
        for(int j = 0; j < lines_train; j++){
            dist[j] = calc_dist(x_train[j], x_test[i], w); //Calcula a distância
        }
        for(int j = 0; j < k; j++){
            double menor = dist[0];
            int index = 0;
            for(int z = 0; z < lines_train; z++){
                if((menor > dist[z]) && (!isHere(z, list))){ //Encontra o vizinho mais próximo
                    index = z;
                    menor = dist[z];
                }
            }
            list->positions[j] = index;
            list->length++; //Mais um vizinho
        }
        result[i] = 0;
        for(int j = 0; j < list->length; j++){
            result[i] += y_train[list->positions[j]];
        }
        result[i] = result[i]/k; //Realizar a previsão através da média
        list->length = 0;
        free(dist);
        free(list->positions);
        free(list);
    }
    return result;

}

bool isHere(int i, list_positions* list){
    if(!list) return false; //Caso inválido
    for(int j = 0; j < list->length; j++){
        if(i == list->positions[j]) return true; //Já foi escolhido vizinho
    }
    return false;//Não foi escolhido ainda
}

double calc_dist(double* x_train, double* x_test, int w){ //Calcula distância euclidiana entre duas linhas
    double aux = 0;
    for(int i = 0; i < w; i++){
        double j = x_train[i] - x_test[i]; // (x1-x2)
        j = pow(j, 2); //(x1 - x2)^2
        aux += j;
    }
    aux = sqrt(aux);
    return aux; //dist(x1, x2)
}