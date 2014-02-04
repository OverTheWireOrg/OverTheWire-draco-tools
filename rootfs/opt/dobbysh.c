#include <stdio.h>
#include <string.h>

int main() {
    char buf[80];
    unsigned long *x;
    unsigned long v;
    char *p;
    
    printf("Hello there\r\n"); fflush(0);
    while(1) {
        fgets(buf, sizeof(buf), stdin);
	if(p = strchr(buf, '\n')) *p = 0;
	if(p = strchr(buf, '\r')) *p = 0;
	if(p = strchr(buf, ' ')) *p++ = 0;
	if(p) {
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
		default:
		    printf("Invalid command. Use \"r <address>\" or \"w <address> <value>\"\n"); fflush(0);
		    break;
	    }
	    
	} else {
		printf("Invalid command. Use \"r <address>\" or \"w <address> <value>\"\n"); fflush(0);
	}
    }

    return 0;
}
