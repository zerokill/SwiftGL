#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int isPrime(int n) {
    if (n <= 1) return 0;
    if (n <= 3) return 1;
    if (n % 2 == 0 || n % 3 == 0) return 0;
    for (int i = 5; i * i <= n; i += 6)
        if (n % i == 0 || n % (i + 2) == 0)
            return 0;
    return 1;
}

double isPrimeBenchmark(int limit) {
    clock_t start = clock();

    long long sum = 0;
    for (int i = 2; i <= limit; i++) {
        if (isPrime(i)) {
            sum += i;
        }
    }

    clock_t end = clock();
    double time_spent = (double)(end - start) / CLOCKS_PER_SEC;

    printf("Sum of primes up to %d: %lld\n", limit, sum);
    printf("Execution time: %.6f seconds\n", time_spent);

    return time_spent;
}
