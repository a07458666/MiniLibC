#include "libmini.h"

typedef void (*proc_t)();
static jmp_buf jb;

#define	FUNBODY(m, from) { write(1, m, strlen(m)); longjmp(jb, from); }

void a() FUNBODY("This is function a().\n", 1);
void b() FUNBODY("This is function b().\n", 2);

proc_t funs[] = { a, b};

int main() {
	volatile int i = 0;
	
	alarm(1);
	
	if(setjmp(jb) != 0) {
		i++;
	}
	if (i == 0)
	{
		write(1, "block alrm\n", strlen("block alrm\n"));
		sigset_t s;
		sigemptyset(&s);
		sigaddset(&s, SIGALRM);
		sigprocmask(SIG_BLOCK, &s, NULL);
	}	
	if(i < 2) funs[i]();
	write(1, "Bingo\n", strlen("Bingo\n"));
	pause();
	return 0;
}
