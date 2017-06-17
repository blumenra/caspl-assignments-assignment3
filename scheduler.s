        global scheduler
        extern resume, end_co


sys_write:      equ   4
stdout:         equ   1

section .data

hello:  db 'scheduler', 10

section .text

scheduler:
        mov ebx, 1
.next:
        ;mov eax, sys_write
        ;mov ebx, stdout
        ;mov ecx, hello
        ;mov edx, 9
        ;int 80h

        call resume             ; resume printer
        loop .next

        call end_co             ; stop co-routines