#include <stdio.h>
#include <stdlib.h>
#include <direct.h>
#include "list.h"
#include "ML.h"
#include <time.h>

LIST_DATA* getData(FILE* file); //Gera a lista ligada dos dados

bool writeFile(char* file_path, double* data, int lines); //Escreve no arquivo

FILE* getFile(char* file_path); //Abre o arquivo

int main(){
    printf("-- KNN para prever o IBOVESPA --\n");
    FILE* file_train = getFile("dados_xtrain.txt"); //Dados de treino
    if(file_train == NULL){
        printf("Erro ao ler o arquivo de treino!\n");
        return 1;
    }
    LIST_DATA* list_train = getData(file_train); //Lista ligada Train
    fclose(file_train);
    int k = 0;
    int w = 0;
    int h = 0;
    char file_test_path[100];
    printf("Digite o parametro K: ");
    scanf("%d", &k);
    printf("Digite o parametro W: ");
    scanf("%d", &w);
    printf("Digite o parametro H: ");
    scanf("%d", &h);
    printf("Digite o nome do arquivo teste: ");
    scanf("%s", file_test_path);
    FILE* file_test = getFile(file_test_path); //Dados de teste
    if(file_test == NULL){
        printf("Erro ao ler o arquivo de teste!\n");
        return 1;
    }
    LIST_DATA* list_test = getData(file_test); //Lista ligada Test
    fclose(file_test);
    clock_t start_time = clock();
    if((k <= 0) || (w <= 0) || (h <= 0)){
        printf("Parametros invalidos!\n");
        return 1;
    }
    double** x_train = NULL;
    double* y_train = NULL;
    int lines_train = 0;
    //Treina o modelo
    if(!split_data(list_train, &x_train, &y_train, &lines_train, w, h)) return 1;
    double** x_test = NULL;
    double* y_test = NULL;
    int lines_test = 0;
    if(!split_data(list_test, &x_test, &y_test, &lines_test, w, h)) return 1;
    //Realiza a regressão
    double* y_pred = knn(x_train, y_train, x_test, lines_train, lines_test, w, k);
    clock_t end_time = clock();
    double cpu_time_used = ((double)(end_time - start_time)) / CLOCKS_PER_SEC;
    printf("Tempo de execucao: %.6f segundos\n", cpu_time_used);
    //Escreve em arquivo
    if(!writeFile("y_test.txt", y_test, lines_test)){
        printf("Erro ao escrever no arquivo!\n");
        return 1;
    }
    if(!writeFile("y_pred.txt", y_pred, lines_test)){
        printf("Erro ao escrever no arquivo!\n");
        return 1;
    }
    //Desaloca memória
    deleteList(list_train);
    deleteList(list_test);
    for(int i = 0; i < lines_train; i++) free(x_train[i]);
    for(int i = 0; i < lines_test; i++) free(x_test[i]);
    free(x_test);
    free(x_train);
    free(y_train);
    free(y_test);
    free(y_pred);
    return 0;
}


FILE* getFile(char* file_path){ //Abre o arquivo
    FILE* file = fopen(file_path, "r");
    return file;
}

bool writeFile(char* file_path, double* data, int lines){ //Escreve em arquivo
    FILE* file = fopen(file_path, "w");
    if(file == NULL) return false;
    for(int i = 0; i < lines; i++){
        fprintf(file, "%.2f\n", data[i]);
    }
    fclose(file);
    return true;
}

LIST_DATA* getData(FILE* file){ //Gera a lista ligada de dados
    char buffer[256];
    LIST_DATA* list = createList();
    while(fgets(buffer, sizeof(buffer), file) != NULL){ //Enquanto há linhas
        char* endPtr;
        double value = strtod(buffer, &endPtr);
        Node* data = createNode(value);
        appendNode(data, list); //Insere o dado na lista
    }
    return list;
}
