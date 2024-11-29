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

LIST_DATA* createList();

Node* createNode(double value);

void appendNode(Node* node, LIST_DATA* list);

void deleteNode(Node* node);

void deleteList(LIST_DATA* list);
#endif