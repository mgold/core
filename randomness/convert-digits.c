#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int main () {
    uint32_t out;
    char buf[16];

    while(fgets(buf, sizeof(buf), stdin)!=NULL)
    {
        buf[10] = '\0';
        out = atoi(buf);
        printf("%02x", out);
    }

}
