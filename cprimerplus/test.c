
#include <stdio.h>
#include <string.h>

#define LEN 15

int main(int argc, char *argv[])
{
    char buf[50];

    // sprintf(buf, "%10s\n", "1235467890123");
    //
    sprintf(buf, "**% d\n", -123546789);
    puts(buf);

    sprintf(buf, "**% d\n", 123546789);
    puts(buf);

    sprintf(buf, "**%+d\n", 123546789);
    puts(buf);

    sprintf(buf, "**%d\n", 123546789);
    puts(buf);

    fputs("************************************\n\n", stdout);

    FILE * fp = fopen("./log", "r+");

    while (fgets(buf, LEN, stdin)) {
        int c, d;
        sscanf(buf, "%d%d\n", &c, &d);
        printf("d is %d, %d\n", c, d);
    }

    printf("Bye!\n");

    // for (int i = 0; i < LEN; ++i) {
    //     if (buf[i] == '\n' || buf[i] == '\0' ) {
    //         buf[i] = 0;
    //         break;
    //     }
    // }

    // sscanf("1235467890123", "%10s\n", buf);
    
    return 0;
}
