        %macro prints 1                ; print string
        pusha
        mov dx, %1
        mov ah, 9
        int 21h
        popa
        %endmacro

        %macro printc 1-*              ; print char
        pusha
        mov ah, 2
        %rep %0
        mov dl, %1
        int 21h
        %rotate 1
        %endrep
        popa
        %endmacro

        %macro printd 1                ; print decimal digit
        pusha
        mov dl, %1
        add dl, 30h
        printc dl
        popa
        %endmacro

        %macro printnl 0               ; print newline
        printc 13, 10
        %endmacro

        %macro exit 0-1 0              ; exit with code (default: 0)
        mov al, %1
        mov ah, 4ch
        int 21h
        %endmacro
