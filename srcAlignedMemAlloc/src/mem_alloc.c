#include "mem_alloc.h"
#include <stdio.h>
#include <assert.h>
#include <string.h>



#ifndef MEMORY_SIZE
#define MEMORY_SIZE 512
#endif



// ----------------------------------
// Data structure for the memory blocks
// ----------------------------------
typedef struct free_block				// < Structure declaration for a free block
{
	int size;
	struct free_block *next;
} free_block_s, *free_block_t;

typedef struct							// < Structure declaration for an occupied block
{
	int size;
} busy_block_s, *busy_block_t;

// ----------------------------------
// Memory definition
// ----------------------------------
char memory[MEMORY_SIZE]; 				// < Hall memory array
free_block_t first_free;				// < Pointer to the first free block in the memory
char memoryAllocationPolicy = MEMORY_FIRST_FIT;




#define ULONG(x)((long unsigned int)(x))
#define max(x,y) (x>y?x:y)




void memory_init(void)
{
	first_free	= (free_block_t) memory;
	first_free->size= MEMORY_SIZE;
	first_free->next= NULL;
}

/**
 *  Allocation main function.
 *  Allocates a contiguous memory block with the requested size.
 *  The allocation algorithm used depends on the policy defined by the macros MEMORY_ALLOCATION_POLICY.
 *  Return the address of the fist usable byte in the allocated memory block (Excluding the block header).
 *  If the requested size is lower than the minimum free block size, the allocated size is equal to the minimum free block size.
 *  If the free block created by the allocation is lower than the minimum free block size, this free block is included in allocated block.
 */
char *memory_alloc(int size)
{
	int actual_size;
	char *addr, test;
	busy_block_t bb;

	switch(memoryAllocationPolicy)
	{
		case MEMORY_FIRST_FIT:	test = findMemory_firstFit(size, &addr, &actual_size);	break;
		case MEMORY_BEST_FIT:	test = findMemory_bestFit(size, &addr, &actual_size);	break;
		case MEMORY_WORST_FIT:	test = findMemory_worstFit(size, &addr, &actual_size);	break;
		default: printFatalError("memory_alloc", "Unknown allocation policy");			break;
	}

	if (!test) return NULL;

	bb = (busy_block_t)addr;
	bb->size = size;
	bb = bb + 1;
	print_alloc_info((char*)bb, size);
	return (char*)bb;
}

/**
 *  Find a memory block corresponding to the request, using the "first fit" policy.
 *  Input parameters:
 * 	- requestedSize:	size of the memory block requested by the user.
 *  Output parameters:
 * 	- addr:				address of the fist byte in the allocated memory block (Including the block header).
 * 	- allocatesSize:	size of the total allocated memory (Including the block header).
 *  Return 0 if no corresponding memory block has been founded and 1 otherwise.
 */
char findMemory_firstFit(int requestedSize, char **addr, int *allocatedSize)
{
	free_block_t freeBlocks = first_free, previous=NULL, newFree;
	int size	= requestedSize + sizeof(busy_block_s);
	int min_fbs	= sizeof(free_block_s);

	if (size < min_fbs)	size = min_fbs;					// < Case: the requested size is smallest than the min size allowed

	while (freeBlocks != NULL)
	{
		if (freeBlocks->size >= size) break;
		previous	= freeBlocks;
		freeBlocks	= freeBlocks->next;
	}
	if (freeBlocks == NULL) return 0;					// < Case: no free block big enough founded
	*addr = (char*)freeBlocks;
	if ((freeBlocks->size - size) <= min_fbs)			// < Case: the created free block size is too small: include it in the allocated block
	{													// < Case: no created free block
		*allocatedSize	= freeBlocks->size;
		if (previous == NULL)	first_free		= freeBlocks->next;
		else					previous->next	= freeBlocks->next;
	}
	else												// < Case: else
	{
		*allocatedSize	= size;
		newFree			= (free_block_t)((char*)freeBlocks + size);
		newFree->size	= freeBlocks->size - size;
		newFree->next	= freeBlocks->next;
		if (previous == NULL)	first_free		= newFree;
		else					previous->next	= newFree;
	}
	return 1;
}
/**
 *  Find a memory block corresponding to the request, using the "best fit" policy.
 *  Input parameters:
 * 	- requestedSize:	size of the memory block requested by the user.
 *  Output parameters:
 * 	- addr:				address of the fist byte in the allocated memory block (Including the block header).
 * 	- allocatesSize:	size of the total allocated memory (Including the block header).
 *  Return 0 if no corresponding memory block has been founded and 1 otherwise.
 */
char findMemory_bestFit(int requestedSize, char **addr, int *allocatedSize)
{
	free_block_t freeBlocks = first_free, previous=NULL, best = NULL, previousBest=NULL, newFree;
	int size	= requestedSize + sizeof(busy_block_s);
	int min_fbs	= sizeof(free_block_s);

	if (size < min_fbs)	size = min_fbs;					// < Case: the requested size is smallest than the min size allowed

	while (freeBlocks != NULL)
	{
		if (freeBlocks->size == size)
		{
			best		= freeBlocks;
			previousBest= previous;
			break;
		}
		if (((best == NULL) && (freeBlocks->size > size)) ||
			(freeBlocks->size <  best->size))
		{
			best		= freeBlocks;
			previousBest= previous;
		}
		previous	= freeBlocks;
		freeBlocks	= freeBlocks->next;
	}
	if (best == NULL) return 0;							// < Case: no free block big enough founded
	*addr = (char*)best;
	if ((best->size - size) <= min_fbs)					// < Case: the created free block size is too small: include it in the allocated block
	{													// < Case: no created free block
		*allocatedSize	= best->size;
		if (previousBest == NULL)	first_free			= best->next;
		else						previousBest->next	= best->next;
	}
	else												// < Case: else
	{
		*allocatedSize	= size;
		newFree			= (free_block_t)((char*)best + size);
		newFree->size	= best->size - size;
		newFree->next	= best->next;
		if (previousBest == NULL)	first_free			= newFree;
		else						previousBest->next	= newFree;
	}
	return 1;
}
/**
 *  Find a memory block corresponding to the request, using the "worst fit" policy.
 *  Input parameters:
 * 	- requestedSize:	size of the memory block requested by the user.
 *  Output parameters:
 * 	- addr:				address of the fist byte in the allocated memory block (Including the block header).
 * 	- allocatesSize:	size of the total allocated memory (Including the block header).
 *  Return 0 if no corresponding memory block has been founded and 1 otherwise.
 */
char findMemory_worstFit(int requestedSize, char **addr, int *allocatedSize)
{
	free_block_t freeBlocks = first_free, previous=NULL, best=NULL, previousBest=NULL, newFree;
	int size	= requestedSize + sizeof(busy_block_s);
	int min_fbs	= sizeof(free_block_s);

	if (size < min_fbs)	size = min_fbs;					// < Case: the requested size is smallest than the min size allowed

	while (freeBlocks != NULL)
	{
		if (((best == NULL) && (freeBlocks->size >= size)) ||
			(freeBlocks->size >  best->size))
		{
			best		= freeBlocks;
			previousBest= previous;
		}
		previous	= freeBlocks;
		freeBlocks	= freeBlocks->next;
	}
	if (best == NULL) return 0;							// < Case: no free block big enough founded
	*addr = (char*)best;
	if ((best->size - size) <= min_fbs)					// < Case: the created free block size is too small: include it in the allocated block
	{													// < Case: no created free block
		*allocatedSize	= best->size;
		if (previousBest == NULL)	first_free			= best->next;
		else						previousBest->next	= best->next;
	}
	else												// < Case: else
	{
		*allocatedSize	= size;
		newFree			= (free_block_t)((char*)best + size);
		newFree->size	= best->size - size;
		newFree->next	= best->next;
		if (previousBest == NULL)	first_free			= newFree;
		else						previousBest->next	= newFree;
	}
	return 1;
}

/**
 *  Free the memory block p and its headers.
 *  May potentially merge the created free block with the previous and the next ones.
 */
void memory_free(char *p)
{
	print_free_info(p); 

	free_block_t previous	= NULL;
	free_block_t next		= first_free, new;
	busy_block_t bb			= (busy_block_t)((char*)p - sizeof(busy_block_s));
	int size = bb->size + sizeof(busy_block_s);

	if (first_free == NULL)													// < Case: full memory
	{
		first_free			= (free_block_t)bb;
		first_free->size	= size;
		first_free->next	= NULL;
		return;
	}
	while(next < (free_block_t)bb)											// < Find the the surrounding free blocks
	{
		previous	= next;
		next		= next->next;
	}
	if (next == (free_block_t)bb) printFatalError("memory_free", "Corrupted memory: busy and free block");
	if (previous != NULL)													// < Merge with previous
	{
		if ((char*)previous + previous->size == (char*)bb)					// <		Case: merge with previous
		{
			previous->size = previous->size + size;
			new = previous;
		}
		else																// <		Case: no merge with previous
		{
			new				= (free_block_t)bb;
			new->size		= size;
			previous->next	= new;
		}
	}
	else																	// <		Case: p is before first_free
	{
		if (next != first_free) printFatalError("memory_free", "Corrupted memory: wrong first_free pointer");
		first_free		= (free_block_t)bb;
		new				= (free_block_t)bb;
		new->size		= size;
	}
																			// < Merge with next
	if		(next == NULL)							new->next = NULL;		// <		Case: no next
	else if ((char*)new + new->size < (char*)next)new->next = next;			// <		Case: no merge
	else if ((char*)new + new->size ==(char*)next)							// <		Case: merge
	{
		new->size	= new->size+next->size;
		new->next	= next->next;
	}
	else printFatalError("memory_free", "Corrupted memory: two overlapped free memory blocks");
}

void printFatalError(char *functionName, char *error)
{
	fprintf(stdout, "*************************\n");
	fprintf(stdout, "Error in the function \"%s\" :\n", functionName);
	fprintf(stdout, "%s\n", error);
	fprintf(stdout, "*************************\n");
	exit(0);
}
void print_info(void)
{
  fprintf(stdout, "Memory : [%lu %lu] (%lu bytes)\n", (long unsigned int) 0, (long unsigned int) (memory+MEMORY_SIZE), (long unsigned int) (MEMORY_SIZE));
  fprintf(stdout, "Free block : %lu bytes; busy block : %lu bytes.\n", ULONG(sizeof(free_block_s)), ULONG(sizeof(busy_block_s)));
}

void print_free_info(char *addr){
  if(addr)
    fprintf(stdout, "FREE  at : %lu \n", ULONG(addr - memory));
  else
    fprintf(stdout, "FREE  at : %lu \n", ULONG(0));
}

void print_alloc_info(char *addr, int size){
  if(addr){
    fprintf(stdout, "ALLOC at : %lu (%d byte(s))\n",
	    ULONG(addr - memory), size);
  }
  else{
    fprintf(stdout, "Warning, system is out of memory\n");
  }
}

void print_free_blocks(void) {
  free_block_t current; 
  fprintf(stdout, "Begin of free block list :\n");
  for(current = first_free; current != NULL; current = current->next)
    fprintf(stdout, "Free block at address %lu, size %u\n", ULONG((char*)current - memory), current->size);
}

char *heap_base(void) {
  return memory;
}


void *malloc(size_t size){
  static int init_flag = 0; 
  if(!init_flag){
    init_flag = 1; 
    memory_init(); 
    //print_info(); 
  }      
  return (void*)memory_alloc((size_t)size); 
}

void free(void *p){
  if (p == NULL) return;
  memory_free((char*)p); 
  print_free_blocks();
}

void *realloc(void *ptr, size_t size){
  if(ptr == NULL)
    return memory_alloc(size); 
  busy_block_t bb = ((busy_block_t)ptr) - 1; 
  printf("Reallocating %d bytes to %d\n", bb->size - (int)sizeof(busy_block_s), (int)size); 
  if(size <= bb->size - sizeof(busy_block_s))
    return ptr; 

  char *new = memory_alloc(size); 
  memcpy(new, (void*)(bb+1), bb->size - sizeof(busy_block_s) ); 
  memory_free((char*)(bb+1)); 
  return (void*)(new); 
}


#ifdef MAIN
int main(int argc, char **argv){

  /* The main can be changed, it is *not* involved in tests */
  memory_init();
  print_info(); 
  print_free_blocks();
  int i ; 
  for( i = 0; i < 10; i++){
    char *b = memory_alloc(rand()%8);
    memory_free(b); 
    print_free_blocks();
  }




  char * a = memory_alloc(15);
  a=realloc(a, 20); 
  memory_free(a);


  a = memory_alloc(10);
  memory_free(a);

  printf("%lu\n",(long unsigned int) (memory_alloc(9)));
  return EXIT_SUCCESS;
}
#endif 
