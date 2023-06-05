
/* width.c -- 字段宽度 */
#include <stdio.h>
#define PAGES 959

int main(void)
{
    printf("*%d*\n",     PAGES);    // *959*
    printf("*%2d*\n",    PAGES);    // *959*
    printf("*%10d*\n",   PAGES);    // *       959*
    printf("*%-10d*\n",  PAGES);    // *959       *
    printf("*%10x*\n",   PAGES);    // *       3bf*
    printf("*%#010x*\n", PAGES);    // *0x000003bf*

    return 0;
}
