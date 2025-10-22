#include <curses.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/time.h>

#define CHAR_BIRD 'O'
#define CHAR_STONE '*'
#define CHAR_BLANK ' '

// Define a linked list node structure for stone obstacles
typedef struct node
{
	int x, y;
	struct node *next;
} node, *Node;

Node head, tail;	// Head and tail of the linked list
int bird_x, bird_y; // Bird character's position
int ticker;			// Timer interval

// Function prototypes
void init();
void init_bird();
void init_draw();
void init_wall();
void init_head();
void drop(int sig);
int set_ticker(int n);
void cleanup();
void free_obstacles();

int main()
{
	char ch;

	init();
	while (1)
	{
		ch = getch();
		if (ch == ' ' || ch == 'w' || ch == 'W')
		{
			// Move the bird character up
			move(bird_y, bird_x);
			addch(CHAR_BLANK);
			refresh();
			bird_y--;
			move(bird_y, bird_x);
			addch(CHAR_BIRD);
			refresh();
			if ((char)inch() == CHAR_STONE)
			{
				// Bird collided with a stone, end the game
				sleep(1);
				cleanup();
				exit(0);
			}
		}
		else if (ch == 'z' || ch == 'Z')
		{
			// Pause the game
			set_ticker(0);
			do
			{
				ch = getch();
			} while (ch != 'z' && ch != 'Z');
			set_ticker(ticker);
		}
		else if (ch == 'q' || ch == 'Q')
		{
			// Quit the game
			sleep(1);
			cleanup();
			exit(0);
		}
	}
	return 0;
}

// Set the timer interval using the ITIMER_REAL timer
int set_ticker(int n_msec)
{
	struct itimerval timeset;
	long n_sec, n_usec;

	n_sec = n_msec / 1000;
	n_usec = (n_msec % 1000) * 1000L;

	timeset.it_interval.tv_sec = n_sec;
	timeset.it_interval.tv_usec = n_usec;
	timeset.it_value.tv_sec = n_sec;
	timeset.it_value.tv_usec = n_usec;

	return setitimer(ITIMER_REAL, &timeset, NULL);
}

// Function called by the timer to move the bird down and update the game
void drop(int sig)
{
	int j;
	Node tmp, p;

	// Move the bird down
	move(bird_y, bird_x);
	addch(CHAR_BLANK);
	refresh();
	bird_y++;
	move(bird_y, bird_x);
	addch(CHAR_BIRD);
	refresh();

	if ((char)inch() == CHAR_STONE)
	{
		// Bird collided with a stone, end the game
		sleep(1);
		cleanup();
		exit(0);
	}

	p = head->next;
	if (p->x < 0)
	{
		// Remove the leftmost stone and create a new one on the right
		head->next = p->next;
		free(p);
		tmp = (node *)malloc(sizeof(node));
		tmp->x = 99;
		do
		{
			tmp->y = rand() % 16;
		} while (tmp->y < 5);
		tail->next = tmp;
		tmp->next = NULL;
		tail = tmp;
		ticker -= 10; // Increase the game speed
		set_ticker(ticker);
	}

	// Update the positions of the stones
	for (p = head->next; p->next != NULL; p->x--, p = p->next)
	{
		for (j = 0; j < p->y; j++)
		{
			move(j, p->x);
			addch(CHAR_BLANK);
			refresh();
		}
		for (j = p->y + 5; j <= 23; j++)
		{
			move(j, p->x);
			addch(CHAR_BLANK);
			refresh();
		}

		if (p->x - 10 >= 0 && p->x < 80)
		{
			for (j = 0; j < p->y; j++)
			{
				move(j, p->x - 10);
				addch(CHAR_STONE);
				refresh();
			}
			for (j = p->y + 5; j <= 23; j++)
			{
				move(j, p->x - 10);
				addch(CHAR_STONE);
				refresh();
			}
		}
	}
	tail->x--;
}

// Initialize the game environment
void init()
{
	initscr();			   // Initialize ncurses
	cbreak();			   // Disable line buffering
	noecho();			   // Disable echoing of input
	curs_set(0);		   // Hide the cursor
	srand(time(0));		   // Seed the random number generator
	signal(SIGALRM, drop); // Register the drop function as a signal handler

	init_bird();
	init_head();
	init_wall();
	init_draw();
	sleep(1);
	ticker = 500;
	set_ticker(ticker); // Set the initial timer speed
}

// Initialize the bird character's position
void init_bird()
{
	bird_x = 5;
	bird_y = 15;
	move(bird_y, bird_x);
	addch(CHAR_BIRD);
	refresh();
	sleep(1);
}

// Create the head node of the linked list for stone obstacles
void init_head()
{
	Node tmp;
	tmp = (node *)malloc(sizeof(node));
	tmp->next = NULL;
	head = tmp;
	tail = head;
}

// Generate the initial set of stones
void init_wall()
{
	int i;
	Node tmp, p;
	p = head;
	for (i = 19; i <= 99; i += 20)
	{
		tmp = (node *)malloc(sizeof(node));
		tmp->x = i;
		do
		{
			tmp->y = rand() % 16;
		} while (tmp->y < 5);
		p->next = tmp;
		tmp->next = NULL;
		p = tmp;
	}
	tail = p;
}

// Draw the initial set of stones
void init_draw()
{
	Node p;
	int i, j;
	for (p = head->next; p->next != NULL; p = p->next)
	{
		for (i = p->x; i > p->x - 10; i--)
		{
			for (j = 0; j < p->y; j++)
			{
				move(j, i);
				addch(CHAR_STONE);
				refresh();
			}
			for (j = p->y + 5; j <= 23; j++)
			{
				move(j, i);
				addch(CHAR_STONE);
				refresh();
			}
		}
		sleep(1);
	}
}

// Free all allocated memory for obstacles
void free_obstacles()
{
	Node current = head;
	Node next;
	
	while (current != NULL)
	{
		next = current->next;
		free(current);
		current = next;
	}
	
	head = NULL;
	tail = NULL;
}

// Cleanup function to properly free resources and exit
void cleanup()
{
	// Stop the timer
	set_ticker(0);
	
	// Free all allocated memory
	free_obstacles();
	
	// End ncurses mode
	endwin();
}
