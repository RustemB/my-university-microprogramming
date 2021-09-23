; *******************************************************
; *                                                     *
; * can't multiply big numbers, try to use 2-digit nums *
; *                                                     *
; *******************************************************

        %include '../INCLUDES/MACROS.ASM'
        %define N 5

        org 100h

        section .text

start:
        call random

        prints msg_arr1
        mov bx, arr1
        call print_arr
        printnl

        prints msg_arr2
        mov bx, arr2
        call print_arr
        printnl

        printnl

        call sum_arrs
        prints msg_sum
        mov bx, arr_res
        call print_arr
        printnl

        prints msg_sub
        call sub_arrs
        mov bx, arr_res
        call print_arr
        printnl

        prints msg_mul
        call mul_arrs
        mov bx, arr_res
        call print_arr
        printnl

        prints msg_div
        ;call div_arrs
        ;mov bx, arr_res
        ;call print_arr
        printc '?'
        printnl
        exit 0h

print_arr:
        mov al, N
        mov si, 0
        printc '['
_loopmain:
        dec al
        push ax
        mov ax, bx[si]
        call print_integer
        pop ax
        inc si
        inc si
        cmp al, 0
        jz _endarr
        printc ','
        printc ' '
        jmp _loopmain
_endarr:
        printc ']'
        ret

random:
        push bx
        push cx
        push dx
        mov ah, 2ch
        int 21h
        xor ax, ax
        inc al
        mov ah, two_arrays_total_elements_count
        mov si, 0
_loop:
        dec ah
        mov bl, dh
        shr bl, 1
        xor bl, dh
        mov dh, dl
        mov dl, cl
        mov cl, al
        mov al, cl
        xor al, bl
        mov bh, cl
        shr bh, 3
        xor al, bh
        mov bh, bl
        shl bh, 1
        xor al, bh
        mov two_arrays[si], ax
        inc si
        inc si
        cmp ah, 0
        jnz _loop

        pop dx
        pop cx
        pop bx
        ret

print_integer:
        push bx
        push cx
        push dx
        xor cx, cx
        xor dx, dx
loop1:
        cmp ax, 0
        je print1
        mov bx, 10
        div bx
        push dx
        inc cx
        xor dx, dx
        jmp loop1
print1:
        cmp cx, 0
        je _exit
        pop dx
        printd dl
        dec cx
        jmp print1
_exit:
        pop dx
        pop cx
        pop bx
        ret

sum_arrs:
        mov si, 0
        mov cx, 0
fillloopsum:
        mov ax, arr1[si]
        mov bx, arr2[si]
        add ax, bx
        mov arr_res[si], ax
        inc si
        inc si
        inc cx
        cmp cx, N
        jne fillloopsum
        ret

sub_arrs:
        mov si, 0
        mov cx, 0
fillloopsub:
        mov ax, arr1[si]
        mov bx, arr2[si]
        sub ax, bx
        mov arr_res[si], ax
        inc si
        inc si
        inc cx
        cmp cx, N
        jne fillloopsub
        ret

mul_arrs:
        mov si, 0
        mov cx, 0
fillloopmul:
        mov ax, arr1[si]
        mov bx, arr2[si]
        mul bx
        mov arr_res[si], ax
        inc si
        inc si
        inc cx
        cmp cx, N
        jne fillloopmul
        ret

; TODO: why not works?
div_arrs:
        mov si, 0
        mov cx, 0
fillloopdiv:
        mov ax, arr1[si]
        mov bx, arr2[si]
        idiv bx
        mov arr_res[si], ax
        inc si
        inc si
        inc cx
        cmp cx, N
        jne fillloopdiv
        ret

        section .data
msg_sum:
        db 'Arrays(sum) = $'
msg_sub:
        db 'Arrays(sub) = $'
msg_mul:
        db 'Arrays(mul) = $'
msg_div:
        db 'Arrays(div) = $'
msg_arr1:
        db 'Array1 is $'
msg_arr2:
        db 'Array2 is $'

        section .bss
two_arrays:
arr1:
        resw N
arr2:
        resw N
        two_arrays_total_elements_count equ ($-two_arrays)/2
arr_res:
        resw N
