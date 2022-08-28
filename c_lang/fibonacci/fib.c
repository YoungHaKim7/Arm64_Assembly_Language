#include <stdio.h>
#include <stdlib.h>

int fib(int n) {
    int i, j;
    if (n < 2)
        return n;
    i = fib(n - 1);
    j = fib(n - 2);
    return (i + j);
}

int main() {
    int n = 40;
    printf("fib(%d) %d \n", n, fib(n));

    return 0;

}
