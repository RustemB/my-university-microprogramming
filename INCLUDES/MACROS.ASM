        %macro prints 1                ; print string
        push dx
        push ax
        mov dx, %1
        mov ah, 9
        int 21h
        pop ax
        pop dx
        %endmacro

        %macro printc 1-*              ; print char
        push dx
        push ax
        %rep %0
        mov dl, %1
        mov ah, 2
        int 21h
        %rotate 1
        %endrep
        pop ax
        pop dx
        %endmacro

        %macro printd 1                ; print decimal digit
        push dx
        push ax
        mov dl, %1
        add dl, 30h
        printc dl
        pop ax
        pop dx
        %endmacro

        %macro printnl 0               ; print newline
        printc 13, 10
        %endmacro

        %macro exit 0-1 0              ; exit with code (default: 0)
        mov al, %1
        mov ah, 4ch
        int 21h
        %endmacro
