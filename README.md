# learning-bios

[本项目地址](https://github.com/StevenBaby/learning-bios)

## BIOS 简介

Basic Input/Output System (BIOS) 位 IBM System/2 和 IBM PC 产品提供了软件接口，使得操作系统和应用程序与具体的硬件设备独立。BIOS 的程序允许汇编语言程序员执行块和字符级别的操作，而无需关心设备地址或者硬件操作的特性。BIOS 同样提供一些系统服务，比如时间和内存大小检测。

操作系统和应用程序应该使用函数请求 BIOS 而不是直接操作 I/O 端口和控制硬件控制字。这样会使得硬件设计和时间变化变得不那么重要，而且软件兼容性跨系统的特性会增强。

## 参考资料

- IBM PS 2 and PC BIOS Interface Technical Reference
- <https://bochs.sourceforge.io/doc/docbook/user/bochsrc.html> bochs configure