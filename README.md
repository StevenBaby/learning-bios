# learning-bios

[本项目地址](https://github.com/StevenBaby/learning-bios)

## BIOS 简介

Basic Input/Output System (BIOS) 位 IBM System/2 和 IBM PC 产品提供了软件接口，使得操作系统和应用程序与具体的硬件设备独立。BIOS 的程序允许汇编语言程序员执行块和字符级别的操作，而无需关心设备地址或者硬件操作的特性。BIOS 同样提供一些系统服务，比如时间和内存大小检测。

操作系统和应用程序应该使用函数请求 BIOS 而不是直接操作 I/O 端口和控制硬件控制字。这样会使得硬件设计和时间变化变得不那么重要，而且软件兼容性跨系统的特性会增强。

## 中断表

| 中断号      | 功能                     |
| ----------- | ------------------------ |
| 0x00        | 除零异常                 |
| 0x01        | 单步调试                 |
| 0x02        | 不可屏蔽中断 NMI         |
| 0x03        | 断点                     |
| 0x04        | 溢出                     |
| 0x05        | 屏幕打印                 |
| 0x06 ~ 0x07 | Intel 保留               |
| 0x08        | 系统定时器               |
| 0x09        | 键盘                     |
| 0x0A ~ 0x0D | Intel 保留               |
| 0x0E        | 磁盘  0x13               |
| 0x0F        | Intel 保留               |
| 0x10        | 视频                     |
| 0x11        | 设备检测                 |
| 0x12        | 内存大小检测             |
| 0x13        | 固定磁盘                 |
| 0x14        | 异步通信                 |
| 0x15        | 系统服务                 |
| 0x16        | 键盘                     |
| 0x17        | 打印机                   |
| 0x18        | BASIC 驻地               |
| 0x19        | 引导装入程序             |
| 0x1A        | 系统定时器和实时时钟服务 |
| 0x1B        | 键盘中断                 |
| 0x1C        | 用户定时器中断           |
| 0x1D        | 视频参数                 |
| 0x1E        | 磁盘参数                 |
| 0x1F        | 视频图像字符             |
| 0x20 ~ 0x3F | DOS 操作系统保留         |
| 0x40        | 磁盘 BIOS 分离器         |
| 0x41        | 固定磁盘参数             |
| 0x42 ~ 0x45 | 保留                     |
| 0x46        | 固定磁盘参数             |
| 0x47 ~ 0x49 | 保留                     |
| 0x4A        | 用户闹钟                 |
| 0x4B ~ 0x5F | 保留                     |
| 0x60 ~ 0x67 | 为用户程序中断保留       |
| 0x68 ~ 0x6F | 保留                     |
| 0x70        | 实时时钟                 |
| 0x71 ~ 0x74 | 保留                     |
| 0x75        | 重定向到不可屏蔽中断     |
| 0x76 ~ 0x7F | 保留                     |
| 0x80 ~ 0x85 | 为 BASIC 保留            |
| 0x86 ~ 0xF0 | BASIC 运行时中断         |
| 0xF1 ~ 0xFF | 为用户程序中断保留       |

## 02H - 不可屏蔽中断 NMI

当看门狗超时有效而且错过了一个时钟中断被检测到时，系统就会产生 NMI，如果此事发生，那么NMI中断处理程序显示 112，指示错过了了一个期望的时钟中断。同样，当 DMA 驱动设备使用总线超过允许的 7.8 微秒，中央仲裁控制点产生一个 NMI 显示 113，指示 DMA 总线超时发生。

当 NMI 发生时，中央仲裁控制点隐式的禁用。NMI 中断处理程序 明确地使得中央仲裁控制点向 90H 端口输出一个 00H。

## 05H - 打印屏幕

> 该中断在 bochs 中无效

该中断处理程序打印屏幕到打印机 1

## 08H - 系统定时器

通过 bochs 我们可以得到下面的代码该中断函数的二进制字符串：

```bin
FB 66 50 1E 31 C0 8E D8 A0 40 04 08 C0 74 10 FE
C8 A2 40 04 75 09 52 BA F2 03 EC 24 CF EE 5A 66
A1 6C 04 66 40 66 3D B0 00 18 00 72 07 66 31 C0
FE 06 70 04 66 A3 6C 04 CD 1C FA E8 ED 93 1F 66
58 CF 
```

可以转换成十六进制整数，使用 Python 存储成具体的二进制文件

```python
# 此处内容中间有省略，去掉上面的字符串空格即可
value = 0xfb66...cf 

# 转换成二进制内容
content =value.to_bytes(length=66, byteorder='big')

# 写入文件
with open('int.bin', 'wb') as file:
   file.write(content)
```

然后进行反汇编

    objdump -D -b binary -m i8086 -M intel int.bin

得到具体的源码：

```s
sti
push   eax
push   ds
xor    ax,ax
mov    ds,ax
mov    al,ds:0x440
or     al,al
je     0x1f
dec    al
mov    ds:0x440,al
jne    0x1f
push   dx
mov    dx,0x3f2
in     al,dx
and    al,0xcf
out    dx,al
pop    dx
mov    eax,ds:0x46c
inc    eax
cmp    eax,0x1800b0
jb     0x34
xor    eax,eax
inc    BYTE PTR ds:0x470
mov    ds:0x46c,eax
int    0x1c
cli    
call   0x942b
pop    ds
pop    eax
iret
```

未完待续...

## 参考资料

- IBM PS 2 and PC BIOS Interface Technical Reference
- <https://bochs.sourceforge.io/doc/docbook/user/bochsrc.html> bochs configure