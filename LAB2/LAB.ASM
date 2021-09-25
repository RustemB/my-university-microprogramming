; TODO: implement correct round floats
; TODO: correct handle ZERO_DIVISION
        %include '../INCLUDES/MACROS.ASM'

        %define N 5

        %macro printi 1                ; prints integer in `ax'
        push ax
        mov ax, %1
        call print_integer
        pop ax
        %endmacro

        %macro printa 2                ; prints array in `bx'
        push bx
        push dx
        mov bx, %1
        mov dx, %2
        call print_arr
        pop dx
        pop bx
        %endmacro

        org 100h

        section .text

start:
        call random                    ; fill `arr1' and `arr2' with random values

; print `arr1'
        prints msg_arr1
        printa arr1, print_integer
        printnl

; print `arr2'
        prints msg_arr2
        printa arr2, print_integer
        printnl

        printnl

; print sum of two arrays
        call sum_arrs
        prints msg_sum
        printa arr_res, print_integer
        printnl

; print sub of two arrays
        call sub_arrs
        prints msg_sub
        printa arr_res, print_integer
        printnl

; print mul of two arrays
        call mul_arrs
        prints msg_mul
        printa arr_res, print_integer
        printnl

; print division of two arrays
        call div_arrs
        prints msg_div
        printa arr_res, print_float
        printnl

        exit 0

print_arr:                             ; function to print array
        mov al, N                      ; count of elems in array (`n')
        mov si, 0                      ; index (`i')
        printc '['
_loopmain:
        dec al                         ; n--
        push ax
        mov ax, bx[si]                 ; print element
        call dx                        ; with provided function
        pop ax
        inc si                         ; i++
        inc si                         ; (we use word size)
        cmp al, 0                      ; if it's last element
        jz _endarr                     ; we do not print comma and space
        printc ','
        printc ' '
        jmp _loopmain
_endarr:
        printc ']'
        ret

random:                                ; procedure to fill two arrays with random integers
        push bx                        ; using xorshift algorithm
        push cx
        push dx
        mov ah, 2ch                    ; set initial variables to current time
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
        xchg cl, al
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

print_float:                           ; print float with one digit after point
        push dx                        ; in memmory it's represent's as (float * 10)
        push bx
        xor dx, dx
        mov bx, 10
        div bx
        printi ax                      ; print ceil part
        printc '.'
        printi dx                      ; print fraction part
        pop bx
        pop dx
        ret

print_integer:                         ; print signed integer
        push bx                        ; divide number by 10
        push cx                        ; push reminder to stack
        push dx                        ; untill it's 0
        xor cx, cx                     ; then pop and print digit with macro printd
        xor dx, dx
        cmp ax, 0
        jne loop1
        printd 0
        jmp _exit
loop1:
        cmp ax, 0
        jge skp
        neg ax                         ; if number is < 0, negate it
        printc '-'                     ; and print minus char
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
        mov dx, 10
        mul dx                         ; store float in array as (nu * 10) / de
        xor dx, dx                     ; for easy storing in memmory
        cmp bx, 0                      ; and printing
        jne _dodiv
        mov ax, 0
        jmp _nodiv
_dodiv:
        div bx
_nodiv:
        mov arr_res[si], ax
_enddiv:
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
