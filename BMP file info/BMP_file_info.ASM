        org 100h

Start:
        mov     ah, $3B
        mov     dx, CurDir
        int     21h

        mov     ah, $1A              ; Задание расположения DTA
        mov     dx, dta
        int     21h



Input:
        push    searchPath
        call    ShowDir

        mov     ah, $09              ;Новая строка
        mov     dx, crlf
        int     21h

     ;   push    searchPathBmp
     ;   call    ShowDir

        mov     ah, $0A
        mov     dx, NewDir
        int     21h

        xor     ax, ax
        mov     bx, NewDir           ; добавление 0
        mov     al, [bx+1]
        add     bx, ax
        xor     ah, ah
        mov     [bx+2], ah
        mov     eax, [bx-2]
        cmp     eax,'.bmp'
        jne     @F


        mov     ah, $09              ;Новая строка
        mov     dx, mes
        int     21h

        call    FileInfo
        jmp     Readkey

@@:
        mov     bx, NewDir+1
        xor     ax, ax

        mov     al, [bx]              ; Выход из программы при пустом вводе

        cmp     al, 0
        je      @F

        add     bx, ax
        xor     ax, ax
        mov     [bx+1], al


        mov     ah, $3B
        mov     dx, NewDir+2
        int     21h

        mov     ah, $09              ;Новая строка
        mov     dx, crlf
        int     21h
        mov     ah, $09              ;Новая строка
        mov     dx, crlf
        int     21h

        jmp     Input
@@:
        mov     ah, $09              ;вывод сообщения
        mov     dx, message
        int     21h

Readkey:
        mov     ax, $0C08
        int     21h
        test    al, al
        jnz     @F
        mov     ah, $08
        int     21h
@@:
        ret

ShowDir:                            ; FindFirstFile
        push    bp
        mov     bp, sp
        mov     ah, $4E
        mov     cx, 00010000b         ; Атрибуты поиска файлов
        mov     dx, [bp+4]
        int     21h
        jc quit

print_filename:
                          ; имя файла находится по смещению 1Eh в DTA и завершается нулем
        mov     ah, $09
        mov     dx, dta + 1eh
        int     21h
        
                                     ; перевод на новую строку
        mov     ah, $09
        mov     dx, crlf
        int     21h
   
                                     ; FindNextFile
        mov     ah, $4F
        mov     dx, dta
        int     21h
        jnc print_filename    ; если ошибки нет - продолжаем вывод списка файлов,
                              ; иначе конец программы
quit:
        pop     bp
        ret     2

FileInfo:

        mov    ax, 3d00h             ; Открытие файла
        mov    dx, NewDir+2
        int    21h

        jnc    @F
.Er:
        mov    ah, 09
        mov    dx, Error
        int    21h
        jmp    .finish

@@:

        push   ax

        mov    bx, ax                ; Чтение файла
        mov    ah, 3fh
        mov    cx, 40
        mov    dx, Buffer
        int    21h

        mov    bx, Buffer
        mov    dx, [bx]
        cmp    dx, 'BM'
        jne    .Er

        mov    ah, 09
        mov    dx, Size
        int    21h

        mov    bx, Buffer            ; Чтение размера файла
        mov    edx, 0
        mov    eax, 0
        mov    dh, [bx+3]
        mov    dl, [bx+2]
        mov    ah, [bx+5]
        mov    al, [bx+4]
        add    edx, eax

        push   edx
        call   PrintDec            ; Вывод на экран размера файла

        mov    ah, 09
        mov    dx, Output
        int    21h

        mov    ah, 09
        mov    dx, Rsl
        int    21h

        mov    bx, Buffer
        mov    edx, 0               ; Вывод на экран разрешения изображения
        mov    eax, 0
        mov    dh, [bx+19]
        mov    dl, [bx+18]
        mov    ah, [bx+21]
        mov    al, [bx+20]
        add    edx, eax

        push   edx
        call   PrintDec

        mov    ah, 02h
        mov    dl, $78
        int    21h

        mov    bx, Buffer
        mov    edx, 0               ; Вывод на экран разрешения изображения
        mov    eax, 0
        mov    dh, [bx+23]
        mov    dl, [bx+22]
        mov    ah, [bx+25]
        mov    al, [bx+24]
        add    edx, eax

        push   edx
        call   PrintDec

        pop    ax

        mov    ah, 3Eh
        mov    bx, ax
        int    21h

.finish:
        ret


PrintDec:                            ;<=== Вывод десятичного числа
        push   bp
        mov    bp, sp

        mov    eax, [bp + 4]
        mov    di, 0

        cmp    ax, 0
        jne    @F
        push   30h
        inc    di
        jmp    zero

@@:
        mov    ebx, 10
        mov    edx, 0
        mov    cx, 5

Cyc:
        cmp    ax, 0
        je     .skip

        div    ebx
        add    dl, '0'
        push   dx
        mov    edx, 0
        inc    di

.skip:
        loop   Cyc

zero:
        mov    cx, di
        mov    ah, 02h

.print:
        pop    dx
        int    21h
        loop   .print

        pop    bp
        ret    4


;C:\Work\FASM\Projects\file\pic.bmp'

;------------------------------------------------------------------------------------
CurDir db 'C:\', 0
searchPath  db "*.*",0                 ; Маски поиска
searchPathBmp db "*.bmp*",0
message db 10, 13, 'Exit...','$'
mes     db 10, 13, 'File info:', 10, 13, '$'
line    db 10, 13, '$'
Error   db 'Error, check file location. ', 10, 13, '$'
Size    db 'Size: $'
Output  db ' Bytes', 10, 13, '$'
Rsl     db 'Resolution: $'
crlf db 10, 13, '$'
NewDir db 64, ?, 64 dup(0)
dta     db 2ch dup (?), '$'
fileloc db 50, ?, 50 dup(?)
Buffer  db ?
