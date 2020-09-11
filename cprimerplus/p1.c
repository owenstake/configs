

/* binbit.c -- 使用位操作显示二进制 */
#include <stdio.h>
#include <limits.h> // 提供 CHAR_BIT 的定义， CHAR_BIT 表示每字节的位数
#include "/home/z/work/mypatch/debugf.h"

char * itobs(int, char *);
void show_bstr(const char *);
int bstoi(char * ps);

int main(void)
{
    char bin_str[CHAR_BIT * sizeof(int) + 1];
    int number;
    puts("Enter integers and see them in binary.");
    puts("Non-numeric input terminates program.");
    while (scanf("%s", bin_str) == 1)
    {
        DEBUG_INFO
        number = bstoi(bin_str);
        printf("result = %d", number);
        putchar('\n');
    } 
    puts("Bye!");
    return 0;
} 

int bstoi(char * ps) {
    int i;
    int mask = 1;
    int r = 0;
    // str word is in big-endien way 
    for (i = strlen(ps) -1; i >=0 ; --i) {
        if(ps[i]-'0') {
            r|=mask;
        }
        mask<<=1;
    }
    return r;
}

char * itobs(int n, char * ps)
{
    int i;
    const static int size = CHAR_BIT * sizeof(int);
    // right to left
    for (i = size - 1; i >= 0; i--, n >>= 1)
        ps[i] = (01 & n) + '0';

    // left to right
    // for (i = 0; i <size; i++, n <<= 1) {
    //     ps[i] = ((0x80000000 & n) ? 1:0) + '0';
    // }

    ps[size] = '\0';
    return ps;
} 

/* 4位一组显示二进制字符串 */
void show_bstr(const char * str)
{
    int i = 0;
    while (str[i]) /* 不是一个空字符 */
    {
        putchar(str[i]);
        // if (++i % 4 == 0 && str[i])
        if (++i % 4 == 0)
            putchar(' ');
    }
}

