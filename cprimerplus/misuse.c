
/* misuse.c -- 错误地使用函数 */
#include <stdio.h>
#include <math.h>

int imax(); /* 旧式函数声明 */
// int imax(int, int); /* 函数原型 */
// int imax(float n, float  m);

int main(void)
{
    // printf("The maximum of %d and %d is %d.\n",3, 5, imax(3, 5));
    printf("The maximum of %d and %d is %d.\n",3, 5, imax(3.1f, 5.1f));
    return 0;
}

int imax(double n, double m)
{
    printf("sizeof(m) = %d\n", sizeof(m));
    printf("sizeof(n) = %d\n", sizeof(n));

    printf("m = %.30f\n", m);
    printf("n = %.30f\n", n);


    printf("sqrt = %f\n", sqrt(0.1234));

    return (n > m ? n : m);
}
