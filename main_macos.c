// C wrapper for MacOS ARM64 assembly example
#include <stdio.h>

// External assembly functions
extern long add_numbers(long a, long b);
extern long multiply_by_two(long n);

int main() {
    printf("=== MacOS ARM64 Assembly Sub Procedure Example ===\n\n");
    
    long num1 = 15;
    long num2 = 27;
    
    printf("Calling add_numbers(%ld, %ld)...\n", num1, num2);
    long sum = add_numbers(num1, num2);
    printf("Result: %ld\n\n", sum);
    
    printf("Calling multiply_by_two(%ld)...\n", sum);
    long doubled = multiply_by_two(sum);
    printf("Result: %ld\n\n", doubled);
    
    printf("Final answer: %ld\n", doubled);
    
    return 0;
}
