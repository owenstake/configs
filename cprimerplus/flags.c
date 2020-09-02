
/* flags.c -- 演示一些格式标记 */
#include <stdio.h>
#define BLURB "Authentic imitation!"

int main(void)
{
    printf("%x %X %#x\n",                    31, 31, 31);
    printf("**%d**% d**% d**\n",             42, 42, -42);
    printf("**%5d**%5.3d**%05d**%05.3d**\n", 6, 6, 6, 6);

    printf("%24s\n", "----------------------------------------------");
    printf("[%2s]\n",     BLURB);
    printf("[%24s]\n",    BLURB);
    printf("[%24.5s]\n",  BLURB);
    printf("[%-24.5s]\n", BLURB);

    return 0;
}
