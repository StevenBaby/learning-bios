
mov ax, 3
int 10h

mov ax, 0xb800
mov ds, ax; 将代码段设置为 0xb800

mov byte [0], 'T'; 修改屏幕第一个字符为 T

; 下面阻塞停下来
halt:
    jmp halt

times 510 - ($ - $$) db 0 ; 用 0 填充满 510 个字节
db 0x55, 0xaa; 主引导扇区最后两个字节必须是 0x55aa
