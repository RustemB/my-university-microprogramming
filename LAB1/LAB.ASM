        %include '../INCLUDES/MACROS.ASM'

        org 100h

        section .text
        prints msg
        exit 0

        section .data
msg:
        db 'Hello, World!', 10, 13, '$'
