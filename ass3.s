        global main
        extern init_co, start_co, resume
        extern scheduler, printer


        ;; /usr/include/asm/unistd_32.h
sys_exit:       equ   1

section .bss
        WorldWidth resb 4
        WorldLength: resb 4
        init_filename: resb 4

section .data
        state: DD 0x00000000
        current_state_break: DD 0x00000000
        new_state_break: DD 0x00000000

section .text

main:
        enter 0, 0

        push dword [ebp+12]
        push dword [ebp+8]
        call setup
        add esp, 8

        mov esi, dword [state]
        mov dword [esi+4], 50
        ;mov dword [current_state_break], 55
        ;add dword [init_filename], 48
        push 4
        mov ecx, esi
        add ecx, 4
        push ecx
        ;push esi
        call print
        add esp, 8


        

        xor ebx, ebx            ; scheduler is co-routine 0
        mov edx, scheduler
        mov ecx, [ebp + 4]      ; ecx = argc
        call init_co            ; initialize scheduler state

        inc ebx                 ; printer i co-routine 1
        mov edx, printer
        call init_co            ; initialize printer state

        ;;;;;;;;
        ;inc ebx                 ; printer i co-routine 1
        ;mov edx, cell
        ;call init_co            ; initialize printer state
        ;;;;;;;;


        xor ebx, ebx            ; starting co-routine = scheduler
        ;call start_co           ; start co-routines


        ;; exit
        mov eax, sys_exit
        xor ebx, ebx
        int 80h

setup:
        push ebp
        mov ebp, esp
        ;****

        mov esi, [ebp+12]       ;point on the first string in argv
        
        ;init states filename
                mov edi, esi
                add edi, 4
                mov edi, dword [edi]
                mov dword [init_filename], edi
        
        ;initialize world length
                mov edi, esi
                add edi, 8
                mov edi, dword [edi]
                mov edi, dword [edi]
                mov dword [WorldLength], edi
                sub dword [WorldLength], 48 ;convert length from char to numeric

        ;initialize world width
                mov edi, esi
                add edi, 12
                mov edi, dword [edi]
                mov edi, dword [edi]
                mov dword [WorldWidth], edi
                sub dword [WorldWidth], 48  ;convert width from char to numeric

        ;initialize cells states array
                call init_states

        ;****
        mov esp, ebp
        pop ebp

        ret

print:
        push ebp
        mov ebp, esp
        ;****

        mov eax, 4
        mov ebx, 1
        mov ecx, dword [ebp+8]
        mov edx, dword [ebp+12]
        int 80h        


        ;****
        mov esp, ebp
        pop ebp

        ret

init_states:
        push ebp
        mov ebp, esp
        ;****

        mov    eax, 45              ;system call brk
        int    0x80
        mov    [current_state_break], eax
        mov    [state], eax


        mov eax, dword [WorldWidth]
        mov ebx, dword [WorldLength]
        mul ebx
        mov ecx, eax


        mov    eax, 45              ;system call brk
        mov    ebx, [current_state_break]
        add    ebx, ecx               ;allocate length*width bytes
        int    0x80
        mov    [new_state_break], eax
        mov    [current_state_break], eax


        ;****
        mov esp, ebp
        pop ebp

        ret

