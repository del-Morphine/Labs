section .data
insert_msg: db "Message:   "
insert_msg_len:    equ $ - insert_msg

insert_key: db "Key:   "
insert_key_len: equ $ - insert_key


section .bss

msg resb 256
key resb 128
msglen resw 1
keylen resw 1
counter resb 2

section .text

global _start

    endl:
        mov eax, 4
        mov ebx, 1
        mov ecx, 0x10
        mov edx, 1
        int 0x80

        ret


    ;args: eax-указатель на начало строки. res: counter. ecx-счётчик
    strlen:
        xor ecx, ecx
        .strlen_next:
            cmp byte [eax], 0   ;Проверка на конец строки
            jz .strlen_end
            inc ecx             ;Увеличиваем счётчик
            inc eax             ;Подбираем адрес следующего символа
            jmp .strlen_next    

        .strlen_end:
            dec ecx             ;Минус один -> длина
            mov [counter], ecx

        ret 

    ;args: eax-указатель на начало строки. ecx-длина строки. progress: ecx-счётчик. res: переданная строка в верхнем регистре
    upper:
        dec ecx                             ;Попадаем на индексы
        .process:
            cmp byte [eax + ecx], 97        
            jb .no                          ;Если символ меньше 97

            cmp byte [eax + ecx], 122
            ja .no                          ;Если символ больше 122

            sub byte [eax + ecx], 32        ;Если попали сюда, то символ прописной и вычитаем 32, чтобы сделать символ заглавным
            dec ecx
            cmp ecx, -1
            je .upper_end
            jmp .process


        .no:                                ;Метка для символов, что не прошли двойное условие выше
            dec ecx                         
            cmp ecx, -1                     ;Узнаем, не закончилась ли строка
            je .upper_end                   ;Если закончилась, то завершаем процесс
            jmp .process                    ;Если не закончилась, то продолжаем

        .upper_end:
    
        ret

    ;args: eax-указатель на строку. progress:ecx, ebx. res: строка, где заглавные буквы переведены в отрезок [0,25]
    subA:
        mov ebx, eax
        call strlen
        .subA_proc:
            dec ecx
            cmp ecx, -1
            je .subA_end

            cmp byte [ebx + ecx], 65
            jb .subA_proc

            cmp byte [ebx + ecx], 90
            ja .subA_proc

            sub byte [ebx + ecx], 65
            jmp .subA_proc

        .subA_end:

        ret



_start:

    ;Оповещение о вводе msg
    mov eax, 4
    mov ebx, 1
    mov ecx, insert_msg
    mov edx, insert_msg_len
    int 0x80


    ;Получаем msg
    mov eax, 3      
    mov ebx, 0
    mov ecx, msg
    mov edx, 256 
    int 0x80

    ;Получаем длину msg и сохраняем её в msglen
    mov eax, msg
    call strlen 
    mov eax, [counter]
    mov [msglen], eax

    ;Превод msg в верхний регистр
    mov eax, msg
    mov ecx, [msglen]
    call upper

    call endl

    ;Оповещение о вводе key
    mov eax, 4
    mov ebx, 1
    mov ecx, insert_key
    mov edx, insert_key_len
    int 0x80

    ;Получаем key
    mov eax, 3      
    mov ebx, 0
    mov ecx, key
    mov edx, 128 
    int 0x80

    ;Получаем длину key и сохраняем её в keylen
    mov eax, key
    call strlen
    mov eax, [counter]
    mov [keylen], eax

    ;Перевод key в верхний регистр
    mov eax, key
    mov ecx, [keylen]
    call upper

    ;Переводим символы msg из отрезка [65,90] в отрезок [0,25]
    lea eax, [msg]
    call subA

    ;Переводим символы key из отрезка [65,90] в отрезок [0,25]
    lea eax, [key]
    call subA


    ;Нужно, чтобы получить в esi длину msg
    xor eax, eax
    mov ax, [msglen]
    mov esi, eax

    ;Нужно, чтобы получить в edi длину key
    xor eax, eax
    mov ax, [keylen]
    mov edi, eax



    encrypt:
    xor ecx, ecx                            ;Обнуление счётчика для msg
    xor edx, edx                            ;Обнуление счётчика для key
        .encryption:

            cmp byte [msg + ecx], 25        ;Если при вводе, этот символ был буквой
            ja .next_char                   ;Если нет, то переходим к следующему символу

            xor eax, eax                    
            xor ebx, ebx
            mov al, [msg + ecx]             ;Кладём в al очередную букву из msg
            mov bl, [key + edx]             ;Кладём в bl очередную букву из key
            add al, bl                      ;m+k
            add al, 65                      ;Нужно, чтобы попасть в диапазон букв в кодировке
            cmp al, 90                      ;Если выходит за диапазон, то вычитаем 26, тогда получим шифр-символ
            ja .division                    ;Иначе, символ уже получен
            .division_end:
            mov [msg + ecx], al             ;Меняем символ msg на шифр-символ

            inc ecx                         ;Счётчик очередного символа msg
            cmp ecx, esi                    ;Если прошли всё сообщение, то выходим
            je .encrypt_end

            inc edx                         ;Счётчик очередного символа key
            cmp edx, edi                    ;Если прошли весь ключ, то возвращаемся на начало ключа
            je .key_setting
            jmp .encryption

            .division:
                sub al, 26
                jmp .division_end

            .next_char:
                inc ecx
                jmp .encryption

            .key_setting:
                xor edx, edx
                jmp .encryption

            .encrypt_end:    

    lea edi, [msglen]              

    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, [edi]
    int 0x80

    mov eax, 1
    int 0x80