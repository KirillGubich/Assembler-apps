         org 100h
Start:
        rdrand ax              ; Генерация случайного числа

        mov    ah, 20h
        mov    dl, 100
        div    dl
        mov    ch, ah
        inc    ch

        mov    si, 10

Return:
        mov    ah, 09
        mov    dx, Mes
        int    21h

        mov    ah, 0Ah         ; Ввод числа
        mov    dx, input
        int    21h

        mov    ah, 09          ; Переход на новую строку
        mov    dx, line
        int    21h

        mov    bx, input       ; Перевод из символьного типа в числовой
        mov    dl, [bx+1]

        mov    ah, 0
        mov    al, [bx+2]
        cmp    al, 30h        ; Проверка корректности ввода
        jl     Return
        cmp    al, 39h
        jg     Return
        sub    al, 30h


        cmp    dl, 2
        jl     @F

        mov    cl, 10
        mul    cl
        mov    cl, [bx+3]
        cmp    cl, 30h        ; Проверка корректности ввода
        jl     Return
        cmp    cl, 39h
        jg     Return
        sub    cl, 30h
        add    al, cl

        cmp    dl, 2
        je     @F

    ;    mov    cl, 10
     ;   mul    cl
      ;  mov    cl, [bx+3]
     ;   cmp    cl, 30h        ; Проверка корректности ввода
     ;   jl     Return
     ;   cmp    cl, 39h
     ;   jg     Return
     ;   sub    cl, 30h
     ;   add    al, cl

@@:
        mov    cl, al
        cmp    cl, 100
        jg     Return

        dec    si

        cmp    cl, ch
        jg     Gr
        jl     Ls

Win:
        mov    ah, 09
        mov    dx, WinMes
        int    21h
        jmp    Finish

Gr:
        mov    ah, 09
        mov    dx, less
        int    21h
        jmp    @f

Ls:
        mov    ah, 09
        mov    dx, greater
        int    21h
        jmp    @f
@@:

        mov    ah, 09         ; Переход на новую строку
        mov    dx, line
        int    21h

        cmp    si, 0
        jnz    Return

        mov    bx, lose       ; Вывод сообщения о поражении
        cmp    ch, 100        ; и неотгаданного числа
        jl     @F

        mov    ah, 0
        mov    al, ch
        mov    dl, 100
        div    dl
        add    al, 30h
        mov    [bx+11], al
        mov    ch, ah

@@:     mov    ah, 0
        mov    al, ch
        mov    dl, 10
        div    dl
        add    al, 30h
        add    ah, 30h
        mov    [bx+12], al
        mov    [bx+13], ah

        mov    ah, 09
        mov    dx, lose
        int    21h


Finish:
        mov    ax, 0C08h
        int    21h
        test   al, al
        jnz    @f
        mov    ah, $08
        int    21h
@@:
        ret

Mes db 'Try to guess:  $'
WinMes db 'You Win!$'
greater db 'Number is greater$'
less db 'Number is less$'
lose db 'The number ',?,?,?,' is not guessed from 10 attempts$'
line db 0ah, 0dh, 0ah, 0dh, '$'
input db 4, 0, 4 dup(?)
