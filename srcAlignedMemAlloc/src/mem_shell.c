
#include <stdio.h>
#include <stdlib.h>

#include "mem_alloc.h"

#define SIZE_BUFFER 128




#ifdef TEACHER_TEST
void aide(void)
{

}
int main(int argc, char *argv[]) {
	char buffer[SIZE_BUFFER];
	char commande;
	int offset;
	int taille;

	aide();
	memory_init();

	while (1) {
		//printf("? ");
		fflush(stdout);
		commande = getchar();
		switch (commande) {
		case 'a':
		  scanf ("%d",&taille);
		  memory_alloc(taille);
		  /*if (adresse == NULL)
		    printf("Allocation failed\n");
		  else
		    printf("Memory allocated at %d\n", (int) (adresse-heap_base()));
*/
		  break;
		case 'f':
		  scanf ("%d",&offset);
		  memory_free(heap_base()+offset);
		  break;
		case 'p':
		  print_free_blocks();
		  break;
		case 'h':
			aide();
			break;
		case 'q':
			exit(0);
		default:
			fprintf(stderr,"Command not found !\n");
		}
		/* vide ce qu'il reste de la ligne dans le buffer d'entree */
		fgets(buffer,SIZE_BUFFER,stdin);
	}
	return 0;
}

#else

void aide(void)
{
	printf("\n\nPlease select: \n");
	printf("\t- a <memory size>:    To allocate a memory block\n");
	printf("\t- f <memory address>: To free the given memory block\n");
	printf("\t- p :                 To print the list of free memory blocks\n");
	printf("\t- h :                 To print this help\n");
	printf("\t- q :                 To properly quit this program\n");
}

int main(int argc, char *argv[])
{
	char buffer[SIZE_BUFFER];
	char commande;
	int offset;
	int taille;

	aide();
	memory_init();

	while (1)
	{
		printf("\n\nChoice:  ");
		fflush(stdout);
		commande = getchar();
		switch (commande)
		{
			case 'a':
			  scanf ("%d",&taille);
			  char * adresse = memory_alloc(taille);
			  if (adresse == NULL)	printf("Allocation failed\n");
			  else					printf("Memory allocated at %d\n", (int) (adresse-heap_base()));
			  break;
			case 'f':
			  scanf ("%d",&offset);
			  memory_free(heap_base()+offset);
			  break;
			case 'p':
			  print_free_blocks();
			  break;
			case 'h':
				aide();
				break;
			case 'q':
				exit(0);
			default:
				fprintf(stderr,"Command not found !\n");
				break;
		}
		/* vide ce qu'il reste de la ligne dans le buffer d'entree */
		fgets(buffer,SIZE_BUFFER,stdin);
	}
	return 0;
}
#endif
