#include "llist.h"

#include <cstdlib>
#include <cstdio>

struct node* create_node(int data)
{
    struct node *result = (struct node *) malloc(sizeof(struct node));
    result->data = data;
    result->next = nullptr;
    return result;
}

int size_of(struct llist* _list) {
    if (_list->head == nullptr) return 0;
    int size = 0;
    struct node* temp = _list->head;
    while(temp) {
        temp = temp->next;
        size++;
    }
    return size;
}

//Recursive
int size_of(struct node* first) {
    if(first == nullptr) return 0;
    else return (size_of(first->next) + 1);
}

void add_end(struct node * first, int data)
{
    struct node *current;
    for(current = first; current->next != NULL; current = current->next);
    struct node *new_node = create_node(data);
    current->next = new_node;
}

void add_end(struct llist * _list, int data)
{
    struct node *new_node = create_node(data);
    _list->tail->next = new_node;
    _list->tail = new_node;
}

void print_list(struct node *first)
{
    struct node *current;
    for(current=first; current!=NULL; current=current->next)
    {
        printf("Node %d\n", current->data);
    }
}

void print_list(struct llist *_list)
{
    struct node *current;
    for(current=_list->head; current!=NULL; current=current->next)
    {
        printf("Node %d\n", current->data);
    }
}

struct node* merge_lists(struct node *first_x,struct node *first_y)
{
    if(first_x == NULL) return first_y;
    if(first_y == NULL) return first_x;
    struct node* result;
    if(first_x->data >= first_y->data)
        result = first_y;
    else
        result = first_x;
    struct node * temp = NULL;
    while(first_x!=NULL && first_y!=NULL)
    {
        /*cout<<first_x->data<<" "<<first_y->data;
        if(temp==NULL)
            cout<<" "<<"NULL"<<endl;
        else
            cout<<" "<<temp->data<<endl;
        */
        for(; first_x->next&&first_x->next->data<first_y->data; first_x=first_x->next);
        for(; first_y->next&&first_y->next->data<first_x->data; first_y=first_y->next);
        if(first_x->data>=first_y->data)
        {
            temp = first_y;
            first_y = first_y->next;
            temp->next=first_x;
        }
        else
        {
            temp = first_x;
            first_x = first_x->next;
            temp->next = first_y;
        }
    }

    return result;
}


struct llist* merge_lists(struct llist *_list1,struct llist *_list2)
{
    if(_list1->head == nullptr) return _list2;
    if(_list2->head == nullptr) return _list1;
    struct llist* result = new llist;
    result->head = _list1->head;
    result->tail = _list1->tail;
    if (result->tail == nullptr) result->tail = new node;
    result->tail->next = _list2->head;
    result->tail = _list2->tail;   
    return result;
}
