// C wrapper for Windows x64 assembly example
#include <stdio.h>

// External assembly functions
extern long long add_numbers(long long a, long long b);
extern long long multiply_by_two(long long n);

int main() {
    printf("=== Windows x64 Assembly Sub Procedure Example ===\n\n");
    
    long long num1 = 15;
    long long num2 = 27;
    
    printf("Calling add_numbers(%lld, %lld)...\n", num1, num2);
    long long sum = add_numbers(num1, num2);
    printf("Result: %lld\n\n", sum);
    
    printf("Calling multiply_by_two(%lld)...\n", sum);
    long long doubled = multiply_by_two(sum);
    printf("Result: %lld\n\n", doubled);
    
    printf("Final answer: %lld\n", doubled);
    
    return 0;
}
