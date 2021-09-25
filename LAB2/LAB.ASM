; TODO: implement correct round floats
        %include '../INCLUDES/MACROS.ASM'

        %define N 5
        %define Inf (99*99)

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
.loop:
        dec al                         ; n--
        push ax
        mov ax, bx[si]                 ; print element
        call dx                        ; with provided function
        pop ax
        inc si                         ; i++
        inc si                         ; (we use word size)
        cmp al, 0                      ; if it's last element
        jz .endarr                     ; we do not print comma and space
        printc ','
        printc ' '
        jmp .loop
.endarr:
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
.loop:
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
        jnz .loop

        pop dx
        pop cx
        pop bx
        ret

print_float:                           ; print float with one digit after point
        push dx                        ; in memmory it's represent's as (float * 10)
        push bx ; 9801 used to Infinity (Inf), as it can't be this value in this task
        cmp ax, Inf ; max value can be = 99.0 (990)
        jne .notinf
        prints is_infinity
        jmp .end
        .notinf:
        xor dx, dx
        mov bx, 10
        div bx
        printi ax                      ; print ceil part
        printc '.'
        printi dx                      ; print fraction part
.end:
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
        jne .loop
        printd 0
        jmp .exit
.loop:
        cmp ax, 0
        jge .skip
        neg ax                         ; if number is < 0, negate it
        printc '-'                     ; and print minus char
.skip:
        je .print
        mov bx, 10
        div bx
        push dx
        inc cx
        xor dx, dx
        jmp .loop
.print:
        cmp cx, 0
        je .exit
        pop dx
        printd dl
        dec cx
        jmp .print
.exit:
        pop dx
        pop cx
        pop bx
        ret

sum_arrs:
        mov si, 0
        mov cx, 0
.fillloop:
        mov ax, arr1[si]
        mov bx, arr2[si]
        add ax, bx
        mov arr_res[si], ax
        inc si
        inc si
        inc cx
        cmp cx, N
        jne .fillloop
        ret

sub_arrs:
        mov si, 0
        mov cx, 0
.fillloop:
        mov ax, arr1[si]
        mov bx, arr2[si]
        sub ax, bx
        mov arr_res[si], ax
        inc si
        inc si
        inc cx
        cmp cx, N
        jne .fillloop
        ret

mul_arrs:
        mov si, 0
        mov cx, 0
.fillloop:
        mov ax, arr1[si]
        mov bx, arr2[si]
        mul bx
        mov arr_res[si], ax
        inc si
        inc si
        inc cx
        cmp cx, N
        jne .fillloop
        ret

div_arrs:
        mov si, 0
        mov cx, 0
.fillloop:
        mov ax, arr1[si]
        mov bx, arr2[si]
        mov dx, 10
        mul dx                         ; store float in array as (nu * 10) / de
        xor dx, dx                     ; for easy storing in memmory
        cmp bx, 0                      ; and printing
        jne .dodiv
        mov ax, Inf
        jmp .nodiv
.dodiv:
        div bx
.nodiv:
        mov arr_res[si], ax
        inc si
        inc si
        inc cx
        cmp cx, N
        jne .fillloop
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
is_infinity:
        db 'Inf$'

        section .bss
two_arrays:
arr1:
        resw N
arr2:
        resw N
        two_arrays_total_elements_count equ ($-two_arrays)/2
arr_res:
        resw N
