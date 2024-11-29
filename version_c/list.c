#include <stdio.h>
#include <stdlib.h>
#include "list.h"

LIST_DATA * createList(){ //Cria uma lista vazia
    LIST_DATA * list;
    list = (LIST_DATA *) malloc(sizeof(LIST_DATA)); //Aloca dinamicamente a lista
    list->head = NULL;
    list->length = 0;
    return list;
}

Node * createNode(double value){ //Cria um nó da lista
    Node * node;
    node = (Node *) malloc(sizeof(Node));
    node->next = NULL;
    node->value = value;
    return node;
}

void appendNode(Node* node, LIST_DATA* list){
    if(node == NULL || list == NULL) return; //Inserção inválida
    Node* it = list->head;
    if(!it) {
        list->head = node;
    }
    else{
        while(it->next){ //Insere no final da lista
            it = it->next;
        }
        it->next = node;
    }
    list->length++; //Incrementa o tamanho da lista
}

void deleteNode(Node* node){
    if(node) {
        free(node); //Libera o espaço alocado
        node = NULL;
    }
}

void deleteList(LIST_DATA* list){
    if(!list) return; //Exclusão inválida
    Node * it = list->head;
    while(it){ //Enquanto há nó
        list->head = list->head->next; //itera
        deleteNode(it); //Libera nó
        it = list->head;
    }
    list->length = 0;
    free(list); //Libera lista
    list = NULL;
}