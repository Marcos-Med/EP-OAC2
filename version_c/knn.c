#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "ML.h"
#include "list.h"

typedef struct 
{
    int* positions;
    int length;
} list_positions; //Estrutura de dados auxiliar


bool split_data(LIST_DATA* data, double** x, double* y, int* lines_data, int w, int h){
    bool flag = (!data) || (!x) || (!y) || (w == 0) || (h == 0);
    if(flag) return false; 
    int lines = data->length - w - h + 1; //Número de linhas
    for(int i = 0; i < lines; i++){
        Node* node = getInit(i, data);
        for(int j = 0; j < w; j++){
             x[i][j] = node->value;
             node->next;
        }
        int posY = i + w + h - 1 //Dia da previsão y[i]
        y[posY] = getInit(posY, data)->value;
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

double* knn(double** x_train, double* y_train, double** x_test, int lines_train, int lines_test, int w, int k){
    double* dist = (double*) malloc(lines_train * sizeof(double));
    double* result = (double*) malloc(lines_test*sizeof(double));
    list_positions* list = (list_positions*) malloc(sizeof(list_positions));
    list->length = 0;
    list->positions = (int*) malloc(sizeof(int) * k);
    for(int i = 0; i < lines_test; i++){
        for(int j = 0; j < lines_train; j++){
            dist[j] = calc_dist(x_train[j], x_test[i], w);
        }
        for(int j = 0; j < k; j++){
            double menor = dist[0];
            int index = 0;
            for(int z = 0; z < lines_train; z++){
                if(menor > dist[z] && (!isHere(z, list))){
                    index = z;
                    menor = dist[z];
                }
            }
            list->positions[j] = index;
            list->length++;
        }
        result[i] = 0;
        for(int j = 0; j < list->length; j++){
            result[i] += y_train[list->positions[j]];
        }
        result[i] = result[i]/k;
        list->length = 0;
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