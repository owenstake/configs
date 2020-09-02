
/* showf_pt.c -- 以两种方式显示float类型的值 */
#include <stdio.h> 
int main(void)
{
    float aboat = 32000.0;
    double abet = 2.14e9;
    long double dip = 5.32e-5;

    printf("%f can be written %e\n", aboat, aboat);

    // 下一行要求编译器支持C99或其中的相关特性
    printf("And it's %a in hexadecimal, powers of 2 notation\n", aboat);
    printf("%f can be written %e\n",                             abet, abet);
    printf("%Lf can be written %Le\n",                           dip, dip);

    // test for ieee float error and significent digit
    //
    // https://zh.wikipedia.org/wiki/IEEE_754
    // 本质的背后是 二进制小数在计算
    printf("%.30f\n", 1-0.9);  // 0.099999999999999977795539507497
    double d2;
    d2 = 0;
    for(int i=0; i<10; i++) {
        d2 += 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1;
        printf("%.30f\n", d2);  // 0.099999999999999977795539507497
    }
    printf("%.30f\n", 0.1);    // 0.100000000000000005551115123126
    printf("%.30f\n", 0.1f);   // 0.100000000000000005551115123126

    printf("%.30f\n", 0.2);    // 0.200000000000000011102230246252
    printf("%.30f\n", 0.5);    // 0.500000000000000000000000000000
    printf("%.30f\n", 1.0);    // 1.000000000000000000000000000000

    printf("%.30Lf\n", 0.2L);  // 0.200000000000000000002710505431
    printf("%.30f\n",  0.2);   // 0.200000000000000011102230246252 double
    printf("%.30f\n",  0.2F);  // 0.200000002980232238769531250000

    // test for float constant
    // 2^24 = 16777216 
    printf("16777217 as float is %.1f\n", (float)16777217);  // 16777216.0
    printf("16777217 as float is %.1f\n", 16777217);         // 16777216.0 float
    printf("16777217 as float is %.1f\n", 16777217.0);       // 16777217.0 double    float const number default for double
    printf("16777217 as float is %.1f\n", (double)16777217); // 16777217.0 

    printf("16777219 as float is %.1f\n", (float)16777219);  // 16777220.0
    printf("16777219 as float is %e\n",   (float)1.67772196);  // 16777220.0
    printf("16777219 as float is %e\n",   (float)1.6777218);  // 16777220.0
    printf("16777219 as double is %.1f\n",  (double)1.677721833333333333333333);  // 16777220.0
    printf("16777219 as double is %f\n",  (double)1.677721833333333333333333);  // 16777220.0

    if(1.0f == 0.99999999999999f) {
        printf("true");
    } else {
        printf("false");
    }

    return 0;
}
