#ifndef _LLIST_H
#define _LLIST_H

struct node {
	int data;
	struct node* next;
};

struct llist{
	struct node* head;
	struct node* tail;
};

struct node* create_node(int data);

int size_of(struct llist* first);

void add_end(struct llist* _list, int data);

void print_list(struct llist *_list);


struct llist* merge_lists(struct llist *_list1, struct llist *_list2);


#endif // _LLIST_H