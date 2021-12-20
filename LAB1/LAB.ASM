        %include '../INCLUDES/MACROS.ASM'

        org 100h

        section .text
        prints msg
        printnl
        exit

        section .data
msg:
        db 'Меня зовут Рустем!$'
