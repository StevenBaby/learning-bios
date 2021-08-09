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
| 0x18        | 启动 BASIC 解释器        |
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

该函数控制系统定时器中断通道0，输入频率 1.19318 MHz / 65536，结果是大约每秒产生 18.2 个中断。

该中断程序：

- 从电源加电开始，在数据区域地址 `40:6C` 维护一个中断的计数器，可能对于统计开机时间有用，24小时候 `40：70` 就会加一
- 将 `40:40`（磁盘驱动器马达的计数器） 地址减一，当该值为 0 时，将关闭磁盘驱动器的马达，而且重置马达运行状态标志 `40：3f`
- 每次定时器中断，通过软中断 `0x1c` 调用一个用户定义的程序。

对于 PC 同样地，当闹钟中断发生时，该中断通过软中断 `0x4a` 调用用户程序。

## 09H - 键盘中断

该中断在每次按键按下或弹起时发出。

对于 ASCII 键，当按下时从 端口号 `60h` 中读出，字符码和扫描码存储在 32 字节键盘缓冲区，在地址 `40:1E`，以及 `40:1C` 键盘缓冲区的尾指针。键盘缓冲区尾指针加 2，除非它扩展超过了缓冲区，这种情况下尾指针就重新初始化为缓冲区开始的位置。

> 简单说就是一个循环队列

对于每个控制字符 `CTRL` `ALT` `SHIFT` 键的按下和弹起，就会更新 BIOS 数据区域 `40:17` 和 `40:18`(键盘控制) 和 `40：96`(键盘模式状态和类型标记)

`CTRL + ALT + DELETE` 引发一个处理程序，设置 `40：72`(重置标记) 为十六进制 `0x1234` (绕开内存检测)，然后跳转到加电自检 (POST Power on self test)，加电自检程序检测重置标记，如果发现时 `0x1234`，加电自检程序将不会再测试内存。（如果该按键序列被按下，应该是之前内存已经测试过了），对于 PC，处理器重置结束时，将调用加电自检执行。

暂停键(PAUSE) 序列将使处理程序进入循环直到一个有效的 ASCII 码被按下，对于 PC `INT 15h; AH=(41H)` (等待一个外部事件) 来等待一个有效的 ASCII 码被按下。

打印屏幕（PrintScreen）键将引发中断 `INT 05H`

`CTRL + BREAK` 序列引发中断 `INT 1BH`

## 10H - 视频中断

视频中断总结

| 参数           | 功能                                    |
| -------------- | --------------------------------------- |
| AH = 00H       | 设置模式                                |
| AH = 01H       | 设置光标类型                            |
| AH = 02H       | 设置光标位置                            |
| AH = 03H       | 读取光标位置                            |
| AH = 04H       | 读取光笔位置                            |
| AH = 05H       | 选择活动显示页                          |
| AH = 06H       | 向上翻页                                |
| AH = 07H       | 向下翻页                                |
| AH = 08H       | 读当前位置的属性/字符                   |
| AH = 09H       | 写当前位置的属性/字符                   |
| AH = 0AH       | 写当前位置的字符                        |
| AH = 0BH       | 设置颜色调色板                          |
| AH = 0CH       | 写点                                    |
| AH = 0DH       | 读点                                    |
| AH = 0EH       | 写电传打字机到活动页                    |
| AH = 0FH       | 读当前视频状态                          |
| AH = 10H       | 设置调色板寄存器                        |
| AH = 11H       | 字符生成器                              |
| AH = 12H       | 替换选择                                |
| AH = 13H       | 写字符串                                |
| AH = 14H       | 加载 LCD 字符字体 / 设置 LCD 高强度替代 |
| AH = 15H       | 返回有效显示器的物理显示参数            |
| AH = 16H ~ 19H | 保留                                    |
| AH = 1AH       | 读/写 显示组合码                        |
| AH = 1BH       | 返回功能/状态信息                       |
| AH = 1CH       | 保存/恢复视频状态                       |
| AH = 1DH ~ FFH | 保留                                    |

## 11H - 设备检测

返回设备列表，BIOS 数据区 `40:10` (安装的硬件) 将在加电自检过程中设置如下：

(AX) - 设备标记

| 位      | 描述                     |
| ------- | ------------------------ |
| 14 ~ 15 | 附加的打印机数量         |
| 13      | 内部调制解调器已安装     |
| 12      | 未使用                   |
| 9 ~ 11  | 附加的 `RS-232-C` 卡数量 |
| 8       | 未使用                   |
| 6 ~ 7   | 磁盘驱动器数量           |
| 4 ~ 5   | 视频模式类型             |
| 3       | 未使用                   |
| 2       | 定点设备已安装           |
| 1       | 数学协处理器已安装       |
| 0       | IPL 磁盘已安装           |

磁盘数量标记：

- 00 / 一个
- 01 / 两个

视频模式标记：

- 00 保留
- 01 40 * 25 彩色
- 10 80 * 25 彩色
- 11 80 * 25 单色

备注：

- 调制解调器：俗称猫，主要进行数模转换
- RS-232-C: 串口标准
- 定点设备：可以认为是鼠标，参见 wikipeidia
- 数学协处理器：可以认为是 FPU，浮点处理器

## 12H - 内存大小检测

此程序返回常规内存的大小，一直到 640KB，减去扩展 BIOS 数据区域分配的内存。

下面是检测内存的一些假设：

- 所有内存都是功能性的
- 所有内存从 0 到 640KB 都是连续的

返回值，在 AX 寄存器中，其中是连续内存块的数量，单位为 1Kb。

## 13H - 固定磁盘

底层磁盘服务

## 14H - 异步通信

串口服务

## 15H - 系统服务

## 16H - 键盘

## 17H - 打印机

## 18H - 启动 BASIC 解释器

在早期的 IBM 机器中，该中断将启动 BASIC 解释器，兼容机没有这个功能，将会有不同的表现，最典型的错误就是没有可启动的磁盘。

## 19H - 引导装入程序

磁道 0，扇区 1 读入 0:0x7c00 的位置，然后控制一些寄存器如下：

- CS = 0000H
- IP - 7C00H
- DL - 引导程序读入扇区的驱动器

如果这里有发生硬件错误，控制转移到 ROM BASIC 入口地址。

## 1AH - 定时器 / 时钟 / PCI

## 1BH - CTRL BREAK 处理程序

当 `CTRL BREAK` 被按下时，通过 `INT 09H` 调用

## 1CH - 定时器处理程序

通过 `INT 08H` 调用

## 1DH - 视频参数

不可能被调用，简单地指向 VPT(Video Parameter Table) 视频参数表，其中包含视频模式数据。

## 1EH - 磁盘参数

不可能被调用，简单地指向 DPT(Diskette Parameter Table) 磁盘参数表，其中包含了很多磁盘驱动器的信息。

## 1FH - 视频图像字符

不可能被调用，简单地指向 VGCT(Video Graphics Character Table) 视频图像字符表，其中包含了 ASCII 80h ~ FFh

## 70H - 实时时钟中断

## 参考资料

- IBM PS 2 and PC BIOS Interface Technical Reference
- <https://bochs.sourceforge.io/doc/docbook/user/bochsrc.html> bochs configure
- <https://en.wikipedia.org/wiki/BIOS_interrupt_call>
- <https://en.wikipedia.org/wiki/Pointing_device>
- <https://en.wikipedia.org/wiki/RS-232>
