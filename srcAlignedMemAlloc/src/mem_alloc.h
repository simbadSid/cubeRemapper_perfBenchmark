#ifndef   	_MEM_ALLOC_H_
#define   	_MEM_ALLOC_H_







//---------------------------------------------
// Memory allocator policy
//---------------------------------------------
#define MEMORY_FIRST_FIT	0
#define MEMORY_BEST_FIT		1
#define MEMORY_WORST_FIT	2


//---------------------------------------------
// Allocator functions, to be implemented in mem_alloc.c
//---------------------------------------------
void memory_init(void); 
char *memory_alloc(int size); 
void memory_free(char *p);


//---------------------------------------------
// Allocator function relative to the chosen policy (used by the allocator function)
//---------------------------------------------
char findMemory_firstFit(int requestedSize, char **addr, int *allocatedSize);
char findMemory_bestFit(int requestedSize, char **addr, int *allocatedSize);
char findMemory_worstFit(int requestedSize, char **addr, int *allocatedSize);


//---------------------------------------------
// Logging functions
//---------------------------------------------
void printFatalError(char *functionName, char *error);
void print_info(void); 
void print_alloc_info(char *addr, int size); 
void print_free_info(char *addr); 
void print_free_blocks(void); 
char *heap_base(void); 

#include <stdlib.h>
//void *malloc(size_t size); 
//void free(void *p); 
//void *realloc(void *ptr, size_t size); 


#endif 	    /* !_MEM_ALLOC_H_ */
