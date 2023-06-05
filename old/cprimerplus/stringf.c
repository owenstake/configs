
/* stringf.c -- 字符串格式 */
#include <stdio.h>
#define BLURB "Authentic imitation!"

int main(void)
{
    printf("[%2s]\n",     BLURB); // [Authentic imitation!]
    printf("[%24s]\n",    BLURB); // [    Authentic imitation!]
    printf("[%24.5s]\n",  BLURB); // [                   Authe]
    printf("[%-24.5s]\n", BLURB); // [Authe                   ]

    return 0;
}
