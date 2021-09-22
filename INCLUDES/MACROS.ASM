        %macro prints 1                ; print string
        push dx
        push ax
        mov dx, %1
        mov ah, 9
        int 21h
        pop ax
        pop dx
        %endmacro

        %macro exit 1                  ; exit with code
        mov al, %1
        mov ah, 4ch
        int 21h
        %endmacro
