;;; This is a simplified co-routines implementation:
;;; CORS contains just stack tops, and we always work
;;; with co-routine indexes.
        global init_co, start_co, end_co, resume

maxcors:        equ 100*100+2         ; maximum number of co-routines
stacksz:        equ 16*1024     ; per-co-routine stack size


section .bss

corsAmount: resb 4         ; maximum number of co-routines
stacks: resb maxcors * stacksz  ; co-routine stacks
cors:   resd maxcors            ; simply an array with co-routine stack tops
curr:   resd 1                  ; current co-routine
origsp: resd 1                  ; original stack top
tmp:    resd 1                  ; temporary value

section .data
        ;stacks: dd 0x00000000
        current_stacks_break: dd 0x00000000
        new_stacks_break: dd 0x00000000

        ;cors: dd 0x00000000
        current_cors_break: dd 0x00000000
        new_cors_break: dd 0x00000000

section .text

        ;; ebx = co-routine index to initialize
        ;; edx = co-routine start
        ;; other registers will be visible to co-routine after "start_co"
init_co:
        
        ;;;;;;;
        ;push ebx
        ;push edx

        ;cmp cors, 0             ; check if cors is already initialized
        ;jne .add_cor
        ;        mov    eax, 45              ;system call brk
        ;        int    0x80
        ;        mov    [current_cors_break], eax
        ;        mov    [cors], eax

        ;.add_cor:
        ;        mov    eax, 45              ;system call brk
        ;        mov    ebx, [current_cors_break]
        ;        add    ebx, 1               ;allocate 8 bytes
        ;        int    0x80
        ;        mov    [new_break], eax
        ;        mov    [current_break], eax


        ;pop edx
        ;pop ebx

        ;.cont:
        ;;;;;;;
        push eax                ; save eax (on caller stack)
		push edx
		mov edx,0
		mov eax,stacksz
        imul ebx		; eax = co-routine stack offset in stacks
        pop edx
		add eax, stacks + stacksz ; eax = top of (empty) co-routine stack
        mov [cors + ebx*4], eax ; store co-routine stack top
        pop eax                 ; restore eax (from caller stack)

        mov [tmp], esp          ; save caller stack top
        mov esp, [cors + ebx*4] ; esp = co-routine stack top

        push edx                ; save return address to co-routine stack
        pushf                   ; save flags
        pusha                   ; save all registers
        mov [cors + ebx*4], esp ; update co-routine stack top

        mov esp, [tmp]          ; restore caller stack top
        ret                     ; return to caller

        ;; ebx = co-routine index to start
start_co:
        pusha                   ; save all registers (restored in "end_co")
        mov [origsp], esp       ; save caller stack top
        mov [curr], ebx         ; store current co-routine index
        jmp resume.cont         ; perform state-restoring part of "resume"

        ;; can be called or jumped to
end_co:
        mov esp, [origsp]       ; restore stack top of whoever called "start_co"
        popa                    ; restore all registers
        ret                     ; return to caller of "start_co"

        ;; ebx = co-routine index to switch to
resume:                         ; "call resume" pushed return address
        pushf                   ; save flags to source co-routine stack
        pusha                   ; save all registers
        xchg ebx, [curr]        ; ebx = current co-routine index
        mov [cors + ebx*4], esp ; update current co-routine stack top
        mov ebx, [curr]         ; ebx = destination co-routine index
.cont:
        mov esp, [cors + ebx*4] ; get destination co-routine stack top
        popa                    ; restore all registers
        popf                    ; restore flags
        ret                     ; jump to saved return address

setup:
        push ebp,
        mov ebp, esp

        mov eax, [ebp+8]        ;eax <= width
        mov ebx, [ebp+12]       ;ebx <= length
        imul ebx                ;eax = eax*ebx
        add eax, 2              ;eax += 2
        mov [corsAmount], eax   ;corsAmount = eax = width*length+2

        


        mov esp, ebp
        pop ebp

        ret