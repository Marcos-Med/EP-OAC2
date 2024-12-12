#ifndef LIST_H
#define LIST_H
typedef struct node
{
    double value;
    struct node * next;
} Node;
   
typedef struct 
{
    Node* head;
    int length;

} LIST_DATA;

LIST_DATA* createList(); //Cria lista

Node* createNode(double value); //Cria Nó

void appendNode(Node* node, LIST_DATA* list); //Insere Nó

void deleteNode(Node* node); //Deleta Nó

void deleteList(LIST_DATA* list); //Deleta lista
#endif