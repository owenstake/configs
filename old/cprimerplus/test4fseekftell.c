#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "/home/z/work/mypatch/debugf.h"

#define ARSIZE 1000

extern char **environ;

int main()
{
    double numbers[ARSIZE];
    double value;
    const char * file = "numbers.dat";
    int i;
    long pos;
    FILE *iofile;
    int a;

    // if ((iofile = fopen(file, "ab+")) == NULL) {
    // if ((iofile = fopen(file, "wb+")) == NULL) {
    // if ((iofile = fopen(file, "wb")) == NULL) {
    if ((iofile = fopen(file, "rb+")) == NULL) {
        fprintf(stderr, "Could not open %s for output.\n", file);
        exit(EXIT_FAILURE);
    } 

    a = 0x01;
    fwrite(&a, sizeof(int), 1, iofile);

    // fseek(iofile, -1L, SEEK_CUR);

    fseek(iofile, 0, SEEK_SET);
    pos = ftell(iofile);
    print_var(pos);

    fseek(iofile, 0, SEEK_END);
    pos = ftell(iofile);
    print_var(pos);

    char c = 60;
    fwrite(&c, sizeof(char), 1, iofile);


    // fread(&a, sizeof(int), 1, iofile);

    // 以二进制格式把数组写入文件
    // fwrite(numbers, sizeof(double), ARSIZE, iofile);
    fclose(iofile);

    puts("Bye!");

    char retstr[100];
    char *re = getenv("ZPLUG_CACHE_DIR");
    print_var(re);

    print_var(environ);

    puts(re);

    return 0;
}

