[org 0x7c00]

mov ax, 3
int 10h

xchg bx, bx

int 0x5

xchg bx, bx

; 下面阻塞停下来
halt:
    jmp halt

times 510 - ($ - $$) db 0 ; 用 0 填充满 510 个字节
db 0x55, 0xaa; 主引导扇区最后两个字节必须是 0x55aa
