        %include '../INCLUDES/MACROS.ASM'

        %ifndef N
        %define N 5
        %endif

        %define Inf 0xffff

        %macro printi 1                ; prints integer in `ax'
        push ax
        mov ax, %1
        call print_integer
        pop ax
        %endmacro

        %macro printa 1-2 _integer     ; prints array in `bx'
        push bx
        push dx
        mov bx, %1
        mov dx, print%[%2]
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
        printa arr1
        printnl

; print `arr2'
        prints msg_arr2
        printa arr2
        printnl

        printnl

; print sum of two arrays
        call sum_arrs
        prints msg_sum
        printa arr_res
        printnl

; print sub of two arrays
        call sub_arrs
        prints msg_sub
        printa arr_res
        printnl

; print mul of two arrays
        call mul_arrs
        prints msg_mul
        printa arr_res
        printnl

; print division of two arrays
        call div_arrs
        prints msg_div
        printa arr_res, _float
        printnl

        exit

print_arr:                             ; function to print array
        mov cx, N                      ; count of elems in array (`n')
        xor si, si                     ; index (`i')
        printc '['
.loop:
        dec cx                         ; n--
        mov ax, bx[si]                 ; print element
        call dx                        ; with provided function
        inc si                         ; i++
        inc si                         ; (we use word size)
        jcxz .endarr                   ; if it's last element we do not print comma and space
        printc 44, 32                  ; comma + space
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
        xor si, si
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
        push cx
        push dx                        ; in memmory it's represent's as (float * 100)
        push bx                        ; 0xFFFF used as Infinity (Inf), as it can't be this value in this task
        cmp ax, Inf                    ; max value can be 99.0 (9900)
        jne .notinf                    ; 99 is max possible value, 0 is minimal
        prints is_infinity
        jmp .end
.notinf:
        xor dx, dx                     ; round fraction part to one digit
        mov bx, 100                    ; by checing second digit after point
        div bx                         ; if second digit is >=5, then increment first
        mov cx, ax                     ; digit by 1
        mov ax, dx                     ; if then first is 10, then print ceil part
        xor dx, dx                     ; point char and 0 (zero)
        mov bx, 10                     ; other wise print it as usual
        div bx
        cmp dx, 5
        jl .L
        inc ax
        cmp ax, 10
        jne .L
        inc cx
        printi cx
        printc '.'
        printd 0
        jmp .end
.L:                                    ; if not inc ceil or first digit
        printi cx
        printc '.'
        printi ax                      ; print fraction part
.end:
        pop bx
        pop dx
        pop cx
        ret

print_integer:                         ; print signed integer
        push bx                        ; divide number by 10
        push cx                        ; push reminder to stack
        push dx                        ; untill it's 0
        xor cx, cx                     ; then pop and print digit with macro printd
        xor dx, dx
        test ax, ax
        jne .loop
        printd 0
        jmp .exit
.loop:
        test ax, ax
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
        xor si, si
        mov cx, N
.loop:
        mov ax, arr1[si]
        mov bx, arr2[si]
        add ax, bx
        mov arr_res[si], ax
        inc si
        inc si
        loop .loop
        ret

sub_arrs:
        xor si, si
        mov cx, N
.loop:
        mov ax, arr1[si]
        mov bx, arr2[si]
        sub ax, bx
        mov arr_res[si], ax
        inc si
        inc si
        loop .loop
        ret

mul_arrs:
        xor si, si
        mov cx, N
.loop:
        mov ax, arr1[si]
        mov bx, arr2[si]
        mul bx
        mov arr_res[si], ax
        inc si
        inc si
        loop .loop
        ret

div_arrs:
        xor si, si
        mov cx, N
.loop:
        mov ax, arr1[si]
        mov bx, arr2[si]
        mov dx, 100
        mul dx                         ; store float in array as (nu * 100) / de
        xor dx, dx                     ; for easy storing in memmory
        test bx, bx                    ; and printing
        jne .dodiv
        mov ax, Inf
        jmp .nodiv
.dodiv:
        div bx
.nodiv:
        mov arr_res[si], ax
        inc si
        inc si
        loop .loop
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
