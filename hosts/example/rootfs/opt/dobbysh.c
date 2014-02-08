#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <stdlib.h>

void help() {
    printf("\n");
    printf("Welcome to Dobby's net-enabled 32-bit memory debugger!\n"); 
    printf("Commands:\n");
    printf("    r <address>: read from address\n");
    printf("    w <address> <value>: write value to address\n");
    printf("    s: show sourcecode of this program\n");
    printf("    b: show binary of this program\n");
    printf("    h: show this help text\n");
    printf("    q: quit\n");
    printf("\n");
    fflush(0);
}

int main() {
    char buf[80];
    unsigned long *x;
    unsigned long v;
    char *p;

    signal(SIGALRM, exit);
    alarm(600);
    
    help();
    while(1) {
        fgets(buf, sizeof(buf), stdin);
	if(p = strchr(buf, '\n')) *p = 0;
	if(p = strchr(buf, '\r')) *p = 0;
	if(p = strchr(buf, ' ')) *p++ = 0;
	if(strlen(buf) > 0) {
	    switch(buf[0]) {
		case 'r': 
		    sscanf(p, "%p", &x);
		    v = *x;
		    printf("Value at %p: %p\n", x, (unsigned long *)v); fflush(0);
		    break;
		case 'w': 
		    sscanf(p, "%p %p", &x, &v);
		    *x = v;
		    printf("Wrote value %p to %p\n", (unsigned long *)v, x); fflush(0);
		    break;
		case 'b': 
		    system("cat /usr/bin/dobbysh");
		    break;
		case 's': 
		    system("cat /opt/dobbysh.c");
		    break;
		case 'q': 
		    printf("Bye!\n"); fflush(0);
		    exit(0);
		    break;
		case 'h': 
		    help();
		    break;
		default:
		    printf("Invalid command. Try 'h' for help\n"); fflush(0);
		    break;
	    }
	    
	} else {
		printf("Invalid command. Try 'h' for help\n"); fflush(0);
	}
    }

    return 0;
}
