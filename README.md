# Scopy
This project implements an assembly function, called from C, with the following declaration:

```
void sum(int64_t *x, size_t n);
```
The function takes as input a pointer x to a non-empty array of 64-bit integers in two's complement representation, and the size n of the array. The function calculates the result according to the following pseudocode:

```
y = 0;
for (i = 0; i < n; ++i)
  y += x[i] * (2 ** floor(64 * i * i / n));
x[0, ..., n-1] = y;
```
Here, ** represents exponentiation, and y is a (64 * n)-bit number in two's complement representation. The function places the result back into the array x in little-endian order.

# Building
To compile the solution, use the following command:

```
nasm -f elf64 -w+all -w+error -o sum.o sum.asm
```
# Example Usage
An example of how to use the sum function can be found in the file sum_example.c. You can compile and link it with the solution using the following commands:

```
gcc -c -Wall -Wextra -std=c17 -O2 -o sum_example.o sum_example.c
gcc -z noexecstack -o sum_example sum_example.o sum.o
```
