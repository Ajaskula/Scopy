; The "scopy" program copies data from one file to another,
; performing the following tasks:

; Check the number of parameters; exit with error code 1
; if the count is not 2.
; Open the input file; exit with error code 1
; if the operation fails.
; Create the output file with permissions -rw-r--r--;
; exit with error code 1 if the creation fails.
; Read from the input file and write to the output file;
; exit with error code 1 if there are read/write errors.
; Copy bytes from the input file to the output file
; if their value is 's' or 'S'.
; Write a 16-bit binary number (little-endian) to the output file,
; representing the count of non-'s'/'S' bytes read.
; Close the files; exit with code 0 if everything is successful.
; The program ensures the proper handling of errors and fulfills
; the given requirements of copying data between files.

; Flags used in syscalls
section .data
    O_EXCL   equ 0200
    O_CREAT  equ 0100
    O_WRONLY equ 01

; Size of buffors used to work with files
section .bss
    buf resb 4096
    number resb 4

section .text
    global _start

_start:
    ; Check if 2 parameters are provided
    pop rax ; place number of arguments from command line
    cmp eax, 3 
    jne exit_w_error_n_closing

    ; Open the in_file for reading
    mov eax, 2 ; sys_open
    mov rdi, [rsp + 8] ; path to the in_file
    xor rsi, rsi ; 0_RDONLY
    syscall

    ; Check if the open operation was successful
    cmp eax, 0
    jl exit_w_error_n_closing

    ; Save the file descriptor of in_file
    mov r9, rax

    ; Check if out_file already exists.
    ; If so, close program with code 1
    ; If no, create out_file with specified permissions
    mov eax, 2 ; sys_open
    mov rdi, [rsp + 16] ; name of out_file to create 
    mov rsi, O_CREAT | O_WRONLY | O_EXCL ; O_CREAT | O_WRONLY | 0_EXCL
    mov edx, 0o644 ; -rw-r--r--
    syscall

    ; Check if creation was successful and there was no file before
    cmp eax, 0
    jl exit_w_error_close_in

    ; Save the file descriptor of out_file
    mov r10, rax

    ; Clear the r8 register
    ; It will be used as non "s" nor "S" byte counter
    xor r8, r8

; Read 4KB from a file into a buffer.
read_to_buf:
    ; Reads 4096 bytes from a file into a buffer.
    xor rax, rax ; sys_read
    mov rdi, r9 ; in_file discriptor
    mov rsi, buf ; pointer to the buffer
    mov edx, 4096 ; max numbers bytes to read
    syscall 

    ; Check if sys_read was successful
    cmp eax, 0
    jl exit_w_error_close_both

    ; Adds last bytes to out file if left
    je add_last_bytes

    ; Number of bytes to process
    mov r12, rax


; Process bytes in the buffer
process_buffer:

    ; Check if there are bytes to process left
    cmp r12, 0
    je read_to_buf; read next piece of bytes from a file

    ; Loads first byte from the buffer to al
    mov al, byte [rsi]

    ; If the byte is 's', jump to the found_s label
    cmp al, 's'
    je found_s

    ; If the byte is 'S', jump to the found_s label
    cmp al, 'S'
    je found_s

    ; Move rsi to point on the next buffer
    inc rsi

    ; Increase the counter of bytes without 's' or 'S'
    mov r8d, [number]
    add r8d , 1
    mov [number], r8d

    ; Decrease number of bytes to process by 1
    sub r12, 1
    
    ; Process next byte
    jmp process_buffer
    

add_last_bytes:

    ; Check if there is positive number to write
    mov rax, [number] 
    cmp eax, 0
    je exit_success_close_both

    ; Write the number of bytes in the last sequence to out_file
    mov eax, 1 ; sys_write
    mov rsi, number ; pointer to the read buffer
    mov rdi, r10 ; in_file discriptor
    mov edx, 2 ; max number of bytes to write
    syscall

    ; Reset no 's' nor 'S' counter
    xor r8, r8
    mov [number], r8d

    ; Check if writing to file was successful
    cmp eax, 0
    jl exit_w_error_close_both

    ; Jump to closing the files
    jmp exit_success_close_both
  
exit_w_error_close_both:
    mov eax, 3 ; sys_close
    mov rdi, r10 ; file discriptor of out_file
    ; Close out_file
    syscall

    ; Check if closing was successful
    cmp eax, 0
    jl exit_w_error_close_both

exit_w_error_close_in:
    mov eax, 3 ; csys_close
    mov rdi, r9 ; file discriptor of in_file
    syscall
    ; Close in_file

exit_w_error_n_closing:
    mov eax, 60 ;sys_exit
    mov edi, 1 ;error code
    syscall
    ; Exit the program with code 1 (error)

exit_success_close_both:
    mov eax, 3 ; sys_close
    mov rdi, r10 ; file discriptor of out_file
    ; Close out_file
    syscall

    ; Check if closing was successful
    cmp eax, 0
    jl exit_w_error_close_in

    mov eax, 3 ; sys_close
    mov rdi, r9 ; file discriptor of in_file
    ; Close in_file
    syscall

    ; Check if closing was successful
    cmp eax, 0
    jl exit_w_error_n_closing

    mov eax, 60 ; sys_exit
    xor rdi, rdi ; error code
    ; Exit the program with code 0 (success)
    syscall

add_bytes:
    mov r13, rsi ; Remember rsi
    mov eax, 1 ; sys_write
    mov rsi, number ; pointer to the read buffer
    mov rdi, r10 ; out_file discriptor
    mov edx, 2 ; max number of bytes to write
    ; Write the number of bytes to out_file
    syscall

    ; Check if writing was successful
    cmp eax, 0
    jl exit_w_error_close_both

    ; reset no 's' or 'S' byte counter
    xor r8, r8
    mov [number], r8d

    mov rsi, r13 ; Recall rsi
    mov eax, 1 ; sys_write
    mov rdi, r10 ; out_file_discriptor
    mov edx, 1 ; max number of bytes to write
    ; Write the 's' or 'S' byte to out_file
    syscall
    inc rsi ; increment buf pointer
    cmp eax, 0
    ; Check if the write operation was successful
    jl exit_w_error_close_both

    ; Process next byte
    jmp process_buffer

found_s:

    sub r12, 1 ; decrement number of bytes to process

    ; If the counter of bytes without 's' or 'S' is not 0, jump to add_bites
    mov rax, r8
    cmp eax, 0
    jne add_bytes

    mov eax, 1 ; sys_write
    mov rdi, r10 ; out_file_discriptor
    mov edx, 1 ; max number of bytes to write
    ; Write the 's' byte to out_file
    syscall
    
    inc rsi ; increment buf ptr

    ; Check if the write operation was successful
    cmp eax, 0
    jl exit_w_error_close_both

    ; Go back to read the next byte
    jmp process_buffer
