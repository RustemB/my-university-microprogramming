        %include '../INCLUDES/MACROS.ASM'
        
        %define N 5
        
        %macro printi 1
        push ax
        mov ax, %1
        call print_integer
        pop ax
        %endmacro

        %macro printa 1
        push bx
        mov bx, %1
        call print_arr
        pop bx
        %endmacro
        
        org 100h

        section .text

start:
        call random

        prints msg_arr1
        printa arr1
        printnl

        prints msg_arr2
        printa arr2
        printnl

        printnl

        call sum_arrs
        prints msg_sum
        printa arr_res
        printnl

        call sub_arrs
        prints msg_sub
        printa arr_res
        printnl

        call mul_arrs
        prints msg_mul
        printa arr_res
        printnl

        call div_arrs
        prints msg_div
        printa arr_res
        printnl

        exit 0

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
        pusha
        xor dx, dx
        mov bx, 100
        div bx
        mov two_arrays[si], dx
        popa
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
        cmp ax, 0
        jne loop1
        printd 0
        jmp _exit
loop1:
        cmp ax, 0
        jge skp
        neg ax
        printc '-'
skp:
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

div_arrs:
        mov si, 0
        mov cx, 0
fillloopdiv:
        mov ax, arr1[si]
        mov bx, arr2[si]
        xor dx, dx
        cmp bx, 0
        jne _dodiv
        mov ax, -1
        jmp _nodiv
_dodiv:
        div bx
_nodiv:
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
