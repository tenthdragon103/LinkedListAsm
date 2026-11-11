%include "io64.inc"

section .data
    struc Node
        .data: resq 1
        .next: resq 1
    endstruc
    
    
    list_size: dq 0
    
    
    err_invalid_input db 'Invalid function input', 0
    err_malloc_fail db 'Failed to allocate necessary memory', 0
    
    msg_node1 db 'Pos: ', 0
    msg_node2 db ' Data: ', 0

section .bss ; uninitialized data section
    list_head: resq 1 ; just a pointer to head, doesnt hold the head itself
    

section .text
global main
global insert
global list_get
global print_list
extern malloc

main:
    mov rbp, rsp; for correct debugging
    mov rdi, 10
    mov rsi, 0
    call insert
    
    mov rdi, 99
    mov rsi, 1
    call insert
    
    call print_list
    
    xor eax, eax ; set return to 0
    ret ; return
    
    
; input DATA: RDI, POS: RSI
; output NODE: RAX
insert:
    test rsi, rsi ; check if insert head
    jl .invalid_input ; lower than 0 invalid
    
    cmp rsi, qword [list_size] ; greater than size invalid
    jge .invalid_input
    
    push rdi ; save data before finding node
    call list_get ; list pos input rsi output ptr rdi    
    call .find_mem ; get mem for new node
    
    mov [rax + Node.next], rdi  ; next node after
    pop rdi ; restore data reg
    mov [rax + Node.data], rdi ; move data into new node
    
    
    test rsi, rsi
    jz .insert_head
    
    inc qword [list_size]
    
; return new position in RAX
.find_mem:
    push rdi ; store rdi because malloc will trash it
    mov rdi, Node_size ; move space needed
    call malloc 
    pop rdi ; restore rdi
    test rax, rax ; check not null
    jz .malloc_fail ; jump if malloc failed
    ret

.insert_head:
    push rdx ; preserve rdx
    mov rdx, qword [list_head] ; temp register
    mov qword [list_head], rax ; update list head pointer
    pop rdx
    ret

.malloc_fail:
    PRINT_STRING err_malloc_fail
    NEWLINE
    ret
    
.invalid_input:
    PRINT_STRING err_invalid_input
    NEWLINE
    ret
    
    
; input POS: RSI
; output PTR: RDI
list_get:
    test rsi, rsi
    jl .invalid_input ; lower than 0 invalid
    
    cmp rsi, list_size - 1
    jg .invalid_input ; greater than size

    mov rcx, rsi ; load pos into counter reg
    mov rdi, [list_head] ; move rdx to real head not ptr

.traverse:
    test rcx, rcx
    jz .done
    
    test rdi, rdi
    jz .invalid_input

    mov rdi, [rdi + Node.next]
    
    dec rcx
    jmp .traverse
    
.done:
    ret
    
.invalid_input:
    PRINT_STRING err_invalid_input
    NEWLINE
    ret
    
    
print_list:
    mov rdi, [list_head]
    mov rcx, 0
    
.loop:
    cmp rcx, qword [list_size]
    jz .done
    
    PRINT_STRING msg_node1
    PRINT_DEC 8, rcx
    PRINT_STRING msg_node2
    PRINT_DEC 8, [rdi + Node.data]
    NEWLINE
    
    mov rdi, [rdi + Node.next]
    inc rcx
    jmp .loop
    
.done:
    ret