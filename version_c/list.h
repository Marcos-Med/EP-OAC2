//Definação da Lista Ligada dos dados de entrada

typedef struct node
{
    int value;
    struct node * next;
} Node;

typedef struct
{
    int length;
    Node * head;

} LIST_DATA;

LIST_DATA * createList();

Node * createNode(int value);

void appendNode(Node* node, LIST_DATA* list);

void deleteNode(Node* node);

void deleteList(LIST_DATA* list);