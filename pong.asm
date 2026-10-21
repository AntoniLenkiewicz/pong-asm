bits 16
cpu 386
org 0x7c00
jmp start

start:
xor ax,ax
mov ds, ax
mov al, 0x13
int 0x10
cld
jmp loop


wpressed:
mov ax, [playery]
sub [playery], 8
cmp [playery], ax
jb nokey
mov [playery], 0
jmp nokey

spressed:
add [playery], 8
cmp [playery], 170
jb nokey
mov [playery], 170
jmp nokey

drawbackground:
mov ax, 0x1000
mov es, ax
mov al, 2
xor di, di
mov cx, 64000
rep stosb
ret

drawmidline:
mov ax, 0x1000
mov ds, ax
mov al, 15
stosb
stosb
add di, 318
cmp di, 0xfa00
jb drawmidline
ret


drawpadle:
mov al, 15
stosb
stosb
stosb
inc cx
add di, 317
cmp cx, 30
jb drawpadle
ret

drawball:
mov al, 48
stosb
stosb
stosb
stosb
add di, 316
inc cx
cmp cx, 4
jb drawball
ret

drawscore:
mov ah, 2
mov dx, 0x0013
int 0x10
mov cx, [score]
cmp ch, 9
je reset
cmp cl, 9
je reset
mov al, ch
add al, '0'
mov ah, 0x0E
mov bx, 0x0f
int 0x10
mov al, cl
add al, '0'
int 0x10
ret
reset:
mov word [score], 0
ret

calculatecords:
imul di, di, 320
add di, dx
ret

tick:
mov ah, 0
int 0x1a
mov bx, dx
.wait:
int 0x1a
cmp bx, dx
je .wait
ret

reversebally:
neg [balldy]
jmp checkxcollision

reverseballx:
neg [balldx]

comparepadle:
cmp ax, [bally]
jg updatescore
add ax, 30
cmp ax, [bally]
jb updatescore
jmp afterballphysics

updatescore:
test bx, bx
mov ax, 160
je .cpuscore
mov [ballx], ax
add word [score], 0x0100
jmp afterballphysics
.cpuscore:
inc byte [score]
mov [ballx], ax
jmp afterballphysics

movecpu:
cmp word [ballx], 100
jb .ret
mov ax, [bally]
cmp word [cpuy],ax
ja .moveup
sub ax, 10
cmp word [cpuy], ax
ja .ret
inc [cpuy]
ret
.moveup:
dec [cpuy]
.ret:
ret

loop:
call tick
xor ax, ax
mov ds, ax
inc ah
int 0x16
jz nokey
xor ah, ah
int 0x16
cmp al, 's'
je spressed
cmp al, 'w'
je wpressed

nokey:
call movecpu
mov al, [balldx]
cbw
add [ballx], ax
mov al, [balldy]
cbw
add [bally], ax
cmp [bally], 0
je reversebally
cmp word [bally], 197
je reversebally
checkxcollision:
cmp word [ballx], 7
mov bx, 0
mov ax, [playery]
jbe reverseballx
cmp word [ballx], 310
mov ax, [cpuy]
inc bx
jae reverseballx
afterballphysics:
push ds

call drawbackground
mov di, 159
call drawmidline

pop ds
push ds
mov di, [bally]
mov dx, [ballx]
call calculatecords
xor cx, cx
call drawball

pop ds
push ds
mov di, [cpuy]
mov dx, 313
call calculatecords
xor cx, cx
call drawpadle

pop ds
push ds
mov di, [playery]
mov dx, 3
call calculatecords
xor cx, cx
call drawpadle
;copy buffer to vga out
mov ax, 0x1000
mov ds, ax
xor si,si

mov ax, 0xa000
mov es, ax
xor di, di

mov cx, 32000
rep movsw

pop ds
call drawscore
jmp loop

score: dw 0
playery: dw 85
cpuy: dw 85
ballx: dw 160
bally: dw 85
balldx: db 4
balldy: db 1
times 510 - ($ - $$) db 0
dw 0xAA55
