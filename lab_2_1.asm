section .data
    msg db "Enter a number", 0xA
    msgLen equ ($ - msg)
    endl db 0xA

    msgErr db "NAN has passed", 0xA
    msgHelp db "Valid str: [digit] [digit] [digit]", 0xA
    msgErrLen equ ($ - msgErr) 

    n db 0x3

segment .bss
    x resb 2
    y resb 2
    z resb 1
    i resb 1        
    j resb 1


section .text
global _start
_start:
    mov eax, 4                
    mov ebx, 0
    mov ecx, msg
    mov edx, msgLen
    int 0x80

    mov eax, 3   
    mov ebx, 1      
    mov ecx, x   
    mov edx, 5 
    int 0x80        

    cmp byte [x], 48
    jb  error
    cmp byte [x], 57
    jg error
    cmp byte [y], 48
    jb  error
    cmp byte [y], 57
    jg error
    cmp byte [z], 48
    jb  error
    cmp byte [z], 57
    jg error

;bubble sort
sort:
    ;i = n - 1
    movzx eax, byte [n]
    mov [i], eax          ;кол-во элементов (3 цифры)
    xor ecx, ecx          ;счётчик внешнего цикла

    .outer_loop: 
        cmp ecx, [i]      ;пока не дошли до последнего элемента
        jge .sort_stop

        ;j = n - 1 - i
        movzx eax, byte [n]
        dec eax
        mov [j], eax
        add [j], eax    ;"умножаем" на 2 из-за "перепрыгивания" пробелов меж. цифрами
        sub [j], ecx    ;по той же причине дважды вычитаем i
        sub [j], ecx
        xor edx, edx    ;и индекс будем увеличивать на 2
        .inner_loop:
            cmp edx, [j]            ;пока не дошли до последней цифры
            jge .inner_loop_stop

            movzx eax, byte [x + edx]       
            movzx ebx, byte [x + edx + 2]
            cmp eax, ebx              ;если eax<ebx, то не меняем
            jbe .next_inner_iteration

            mov [x + edx], bl       ;меняем
            mov [x + edx + 2], al

            .next_inner_iteration:
                add edx, 2          ;увелчиваем индекс на 2, т.к. прыгаем через пробел
                jmp .inner_loop     
            
            .inner_loop_stop:
                inc ecx             
                jmp .outer_loop     ;переходим на след. итерацию внеш.цикла

    .sort_stop:

    ;вывод результата
    mov eax, 4                
    mov ebx, 0
    mov ecx, x
    mov edx, 5
    int 0x80

    ;переход на новую строку
    mov eax, 4                
    mov ebx, 0
    mov ecx, endl
    mov edx, 1
    int 0x80

exit:   
    mov eax, 1   
    mov ebx, 0      
    int 0x80 

error:
    mov eax, 4                
    mov ebx, 0
    mov ecx, msgErr
    mov edx, msgErrLen
    int 0x80
    jmp exit

