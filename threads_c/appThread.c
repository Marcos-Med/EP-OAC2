#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include "../version_c/list.h"
#include "../version_c/ML.h"
#include "threads.h"

LIST_DATA* getData(char* file_path);//Gera a lista de dados

bool writeFile(char* file_path, double* data, int lines); //Escreve os dados no arquivo

FILE* getFile(char* file_path); //Abre um arquivo

//Código que utiliza OpenMP para realizar o paralelismo
int main(){

    printf("-- KNN para prever o IBOVESPA --\n");
    LIST_DATA* list_train = getData("../x_train.txt"); //Lista ligada Train
    LIST_DATA* list_test = getData("../x_test.txt"); //Lista ligada Test
    int k = 0;
    int w = 0;
    int h = 0;
    printf("Digite o parametro K: ");
    scanf("%d", &k);
    printf("Digite o parametro W: ");
    scanf("%d", &w);
    printf("Digite o parametro H: ");
    scanf("%d", &h);
    double start_time = omp_get_wtime();
    if((k <= 0) || (w <= 0) || (h <= 0)){
        printf("Parametros invalidos!\n");
        return 1;
    }
    double** x_train = NULL;
    double* y_train = NULL;
    int lines_train = 0;
    if(!split_data(list_train, &x_train, &y_train, &lines_train, w, h)) return 1;
    double** x_test = NULL;
    double* y_test = NULL;
    int lines_test = 0;
    if(!split_data(list_test, &x_test, &y_test, &lines_test, w, h)) return 1;
    double* y_pred = knn(x_train, y_train, x_test, lines_train, lines_test, w, k);
    double end_time = omp_get_wtime();
    double elapsed_time = end_time - start_time;
    printf("Tempo de execucao: %.6f segundos\n", elapsed_time);
    if(!writeFile("y_test.txt", y_test, lines_test)){
        printf("Erro ao escrever no arquivo!\n");
        return 1;
    }
    if(!writeFile("y_pred.txt", y_pred, lines_test)){
        printf("Erro ao escrever no arquivo!\n");
        return 1;
    }
    deleteList(list_train);
    deleteList(list_test);
    #pragma omp parallel for num_threads(NUM_THREADS)
    for(int i = 0; i < lines_train; i++) free(x_train[i]);
    #pragma omp parallel for num_threads(NUM_THREADS)
    for(int i = 0; i < lines_test; i++) free(x_test[i]);
    free(x_test);
    free(x_train);
    free(y_train);
    free(y_test);
    free(y_pred);
    return 0;
}

FILE* getFile(char* file_path){
    FILE* file = fopen(file_path, "r");
    return file;
}

LIST_DATA* getData(char* file_path){
    FILE* file = getFile(file_path);
    //Obter o tamanho do arquivo
    fseek(file, 0, SEEK_END); //Move o cursor ao final do arquivo
    long size_file = ftell(file); //Recebe o tamanho
    rewind(file); //Retorna ao início do arquivo
    fclose(file);
    long block_size = size_file / NUM_THREADS;

    LIST_DATA* list = createList();
    int tam_list = 0;
    Node* nodes[NUM_THREADS*2 - 2];
    Node* init;
    #pragma omp parallel reduction(+:tam_list) num_threads(NUM_THREADS)
    {
        int thread_id = omp_get_thread_num();
        long start = thread_id * block_size;
        long end = (thread_id < NUM_THREADS - 1) ? start + block_size - 10 : size_file;
        char buffer[256];
        FILE* fDATA = getFile(file_path);
        fseek(fDATA, start, SEEK_SET);
        LIST_DATA* list_local = createList();
        Node* node;
        while(ftell(fDATA) < end && fgets(buffer, sizeof(buffer), fDATA)){
            char* endPtr;
            double value = strtod(buffer, &endPtr);
            node = createNode(value);
            appendNode(node, list_local);
        }
        fclose(fDATA);
        tam_list = list_local->length;
        if(thread_id == 0) {
            nodes[thread_id] = node;
            init = list_local->head;
        }
        else if(thread_id == NUM_THREADS - 1) nodes[thread_id*2 - 1] = list_local->head;
        else{
            nodes[thread_id*2 - 1] = list_local->head;
            nodes[thread_id*2] = node;
        }
    }
    for(int i = 0; i < (NUM_THREADS*2-3); i+=2){
        Node* a = nodes[i];
        a->next = nodes[i+1];
    }
    list->head = init;
    list->length = tam_list;
    return list;
}

bool writeFile(char* file_path, double* data, int lines){
    FILE* file = fopen(file_path, "w");
    if(file == NULL) return false;
    for(int i = 0; i < lines; i++){
        fprintf(file, "%.2f\n", data[i]);
    }
    fclose(file);
    return true;
}