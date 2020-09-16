#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "/home/z/work/mypatch/debugf.h"

#define ARSIZE 1000

extern char **environ;
extern void display(char cr, int lines, int width);

int main()
{
    double numbers[ARSIZE];
    double value;
    const char * name = "numbers.dat";

    char * re = strchr(name, 'e');

    printf("%s\n", re);

    print_var(re);

    int ch; /* 待打印字符 */
    int rows, cols; /* 行数和列数 */

    printf("Enter a character and two integers:\n");
    // while ((ch = getchar()) != '\n'){
    //     printf("%c", ch);
    // }
    // while ((ch = getchar()) != '\n')
    // {
    //     scanf("%d %d", &rows, &cols);
    //     display(ch, rows, cols);
    //     while (getchar() != '\n')
    //         continue;
    //     printf("Enter another character and two integers;\n");
    //     printf("Enter a newline to quit.\n");
    // }

    int n;
    int a=100;
    char str[50];
    char c;

    float f;
    double d;

    scanf("%lf", &d);
    printf("%lf\n", d);

    while (scanf("%ld", &n) == 1 && n >= 0) {
        printf("Integer = %d\n", n);
    }

    printf("Bye.\n");

    return 0;
}

void display(char cr, int lines, int width){
    int row, col;
    for (row = 1; row <= lines; row++)
    {
        for (col = 1; col <= width; col++)
            putchar(cr);
        putchar('\n');/* 结束一行并开始新的一行 */
    }
}
