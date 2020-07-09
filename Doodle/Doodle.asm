        org 100h

Start:
        ; Получение параметров текущего видеорежима
        mov     ah, $0F
        int     10h
        mov     [bOldMode], al
        mov     [bOldPage], bh

        ; Переключение в режим №13
        mov     ax, $0013
        int     10h

        xor     bp, bp

        call    DrawSky
Return:
        call    DrawDoodle
        call    ReadKey

        inc     bp

        cmp     al, ' '
        jne     @F

        mov     ax, bp
        mov     bl, 3
        div     bl
        cmp     ah, 1
        je      .Paper
        ja      .Space
        call    DrawSky
        jmp     .Continue

.Paper:
        call    DrawPaper
        jmp     .Continue

.Space:
        call    DrawSpace

.Continue:
        jmp     Return

@@:

        ; Восстановление исходного видеорежима и теущей видеостраницы
        movzx   ax, [bOldMode]
        int     10h
        mov     ah, $05
        mov     al, [bOldPage]
        int     10h
        ret

ReadKey:                     ; Ожидание нажатия
        mov     ax, $0C08
        int     21h
        movzx   dx, al
        test    al, al
        jnz     @F
        mov     ah, $08
        int     21h
        mov     dh, al
@@:
        mov     ax, dx
        ret

DrawSqr:                  ; Процедура для отрисовки квадрата
        push    di
        push    cx

        mov     dh, 10
@@:
        mov     cx, 10
        rep stosb
        add     di, 310

        dec     dh
        cmp     dh, 0

        ja      @B

        pop     cx
        pop     di

        add     di, 10

        ret

DrawRec:                      ; Процедура для отрисовки прямоугольника
        push    bp            ; Первый параметр - длина
        mov     bp, sp        ; Второй параметр - ширина

        push    di
        push    cx

        mov     dh, [bp+4]
@@:
        mov     cx, [bp+6]
        rep stosb
        add     di, 320
        sub     di, [bp+6]

        dec     dh
        cmp     dh, 0

        ja      @B

        pop     cx
        pop     di

        pop     bp
        ret     4

DrawRay:                      ; Процедура для отрисовки луча
        push    bp            ; Параметр 1 - расположение
        mov     bp, sp
        push    di

        mov     di, [bp+4]
        mov     al, $2C
        mov     cx, 3

.Cycle:
        call    DrawSqr
        add     di, 300+320*9
        loop    .Cycle

        pop     di
        pop     bp
        ret     2

DrawDoodle:                   ; Процедура для отрисовки персонажа

        mov     ax, $A000
        mov     es, ax

        mov     di, 6430
        xor     al, al
        push    80
        push    10
        call    DrawRec

        add     di, 250+9*320+60

        call    DrawSqr

        mov     al, $2C
        push    80
        push    10
        call    DrawRec

        add     di, 80
        mov     al, $0
        call    DrawSqr

        mov     di, 40*320+10
        push    10
        push    110
        call    DrawRec

        add     di, 10
        mov     al, $2C
        push    100
        push    70
        call    DrawRec

        add     di, 100
        xor     al, al
        push    10
        push    30
        call    DrawRec

        mov     di, 60*320+80
        call    DrawSqr

        add     di, 10
        call    DrawSqr

        add     di, 20
        push    60
        push    10
        call    DrawRec

        add     di, 3190
        mov     al, $2C
        push    40
        push    10
        call    DrawRec

        add     di, 40

        xor     al, al
        call    DrawSqr

        mov     al, $2C
        call    DrawSqr

        xor     al, al
        call    DrawSqr

        mov     di, 80*320+120
        mov     al, $2C
        call    DrawSqr

        xor     al, al
        push    60
        push    10
        call    DrawRec

        mov     di, 90*320+120
        call    DrawSqr

        add     di, 320*10-10
        call    DrawSqr

        mov     di, 110*320+20
        push    110
        push    10
        call    DrawRec

        add     di, 10*320

        mov     al, $76
        push    100
        push    10
        call    DrawRec

        add     di, 100
        xor     al, al
        push    10
        push    30
        call    DrawRec

        mov     di, 130*320+20
        mov     al, $76
        push    100
        push    10
        call    DrawRec

        add     di, 320*10
        xor     al, al
        push    100
        push    10
        call    DrawRec

        add     di, 320*10
        push    10
        push    30
        call    DrawRec

        mov     cx, 3

.Cycle1:
        add     di, 30
        push    10
        push    30
        call    DrawRec
        loop    .Cycle1

        mov     di, 170*320+30
        mov     cx, 4

.Cycle2:
        call    DrawSqr
        add     di, 20
        loop    .Cycle2

        ret

DrawSky:                     ; Процедура для отрисовки фона неба

        push    di

        mov     ax, $A000
        mov     es, ax

        xor     di, di

        mov     al, $4F
        mov     cx, 64000
        rep     stosb

        mov     al, $2C
        mov     di, 270
        push    50
        push    50
        call    DrawRec

        push    260
        call    DrawRay

        push    25*320+260
        call    DrawRay

        push    50*320+260
        call    DrawRay

        push    50*320+285
        call    DrawRay

        push    50*320+310
        call    DrawRay

        pop     di
        ret

DrawPaper:              ; Процедура для отрисовки фона клетчатой бумаги

        push    di
        push    si

        mov     ax, $A000
        mov     es, ax

        xor     di, di
        mov     al, $0F
        mov     cx, 64000
        rep     stosb

        mov     di, 320*19
        xor     si, si
        mov     al, $01

.Row:
        push    320
        push    1
        call    DrawRec

        add     di, 320*20
        inc     si
        cmp     si, 9
        jb      .Row

        mov     di, 20
        xor     si, si
.Col:
        push    1
        push    200
        call    DrawRec
        add     di, 20
        inc     si
        cmp     si, 15
        jb      .Col

        pop     si
        pop     di

        ret

DrawSpace:                  ; Процедура для отрисовки фона космоса

        mov     ax, $A000
        mov     es, ax

        xor     di, di
        mov     al, $22
        mov     cx, 64000
        rep     stosb

        mov     di, 160+320*4
        mov     al, $1F
        Call    DrawSqr

        mov     di, 270+320*13
        mov     al, $1F
        Call    DrawSqr

        mov     di, 300+320*24
        mov     al, $1F
        Call    DrawSqr

        mov     di, 275+320*64
        mov     al, $1F
        Call    DrawSqr

        mov     di, 200+320*94
        mov     al, $1F
        Call    DrawSqr

        mov     di, 240+320*124
        mov     al, $1F
        Call    DrawSqr

        mov     di, 150+320*150
        mov     al, $1F
        Call    DrawSqr

        mov     di, 274+320*171
        mov     al, $1F
        Call    DrawSqr

        ret


bOldMode        db      ?
bOldPage        db      ?