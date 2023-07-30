# Special File Copying
Implement an assembly program called scopy, which takes two parameters as file names:

```
./scopy in_file out_file
```
The program checks the number of parameters. If the number is not equal to 2, the program exits with code 1.

The program attempts to open the in_file for reading. If it fails, the program exits with code 1.

Next, the program tries to create a new file out_file with permissions -rw-r--r--. If it fails, for example, because such a file already exists, the program exits with code 1.

The program reads from in_file and writes to out_file. If any read or write errors occur, the program exits with code 1.

For each byte read from in_file, whose ASCII value represents the letter 's' or 'S', the program writes that byte to out_file.

For each maximal non-empty sequence of bytes read from in_file that does not contain the byte representing the letter 's' or 'S', the program writes a 16-bit number to out_file. This number represents the count of bytes in that sequence modulo 65536 and is written in binary in little-endian order.

Finally, the program closes the files, and if everything is successful, it exits with code 0.

# Compilation:
To compile the solution, use the following commands:

```
nasm -f elf64 -w+all -w+error -o scopy.o scopy.asm
ld --fatal-warnings -o scopy scopy.o
```

Example Usage:
An example of how to use the scopy program can be found in the attached files example1.in and example1.out. You can view the contents of these files using the hexdump -C command.
