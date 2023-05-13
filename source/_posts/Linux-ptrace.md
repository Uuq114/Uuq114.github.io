---
title: Linux ptrace
top: 0
copyright: true
date: 2021-12-04 21:27:52
updated: 2021-12-04 21:27:52
permalink:
password:
comments:
tags:
- Linux
categories:
- 操作系统
keywords:
description:
---

# 简介

最近的项目中需要用到`ptrace`这样的系统调用函数，这里总结一下要注意的地方。

<!-- more -->

## 系统调用

在编写程序的时候，我们会使用编程语言提供的库函数，例如`read()`、`fork()`，这些库函数实际上是对一些底层操作的包装。这些底层操作就称为系统调用。

一个系统调用包括：

* 编号，用于区分
* 参数
* 寄存器，用于存放参数



例如，`write()`会被转换成：

```asm
write(2, "Hello", 5);
/*----------------*/
movl $1,%eax	; 系统调用号
movl $2,%ebx
movl $hello,%ecx
movl $5,%edx
int $0x80		; 中断
```



## `ptrace`

`ptrace`可以让一个进程（tracer）监视和控制另一个进程（tracee），并且可以改变内存和寄存器的内容，一般用于debug。

`ptrace`起作用的时间：在执行system call之前，kernel会检查process是否被追踪。如果是的，那么kernel会中止tracee并将控制权交给追踪者。



**一个例子**：

```c
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/user.h> // ORIG_RAX
#include <sys/reg.h> // ORIG_RAX
#include <stdio.h>

int main() {
    pid_t child;
    long orig_eax;
    child = fork();
    if(child == 0) {
        ptrace(PTRACE_TRACEME, 0, NULL, NULL);
        execl("/bin/ls", "ls", NULL);
    }
    else {
        wait(NULL);
        orig_eax = ptrace(PTRACE_PEEKUSER,
                          child, 8 * ORIG_RAX, // 在64位的机器上，所以要乘8，如果是32位乘4
                          NULL);
        /* 也可以用下面的方法得到orig_eax，不需要计算register位置
       	struct user_regs_struct regs;
		ptrace(PTRACE_GETREGS, child, NULL, &regs);
		printf("The child made a system call %ldn", regs.orig_rax);
        */
        printf("The child made a "
               "system call %ld\n", orig_eax);
        ptrace(PTRACE_CONT, child, NULL, NULL);
    }
    return 0;
}
```

输出是：

![output](output.png)

对例子的分析：

在12行调用了`fork`，child会先调用`ptrace`，`flag`为`PTRACE_TRACEME`，告诉kernel它正在被追踪，于是在child执行`execve` system call时，控制权会被交给parent。

parent使用`wait`等待kernel的通知。之后parent可以检视参数（读register）。

当系统调用发生时，kernel会保存eax的内容，parent可以用`ptrace`的`PTRACE_PEEKUSER`参数读这个值，如19行。

parent完成检视之后，以`PTRACE_CONT`参数调用`ptrace`，可以继续system call。

> 运行的结果是`59`，和原网址的结果`11`不同，原因是什么？
>
> `asm/unistd.h`文件在i386、ILP32和64位机上的不同，`asm/unistd_64.h`中有：`#define __NR_execve 59`



`ptrace`的**用法**：

```c
long ptrace(enum __ptrace_request request,
            pid_t pid,
            void *addr,
            void *data);
```

`request`参数指定了`ptrace`的行为和后面参数的用法。

> `PTRACE_TRACEME`, `PTRACE_PEEKTEXT`, `PTRACE_PEEKDATA`, `PTRACE_PEEKUSER`, `PTRACE_POKETEXT`, `PTRACE_POKEDATA`, `PTRACE_POKEUSER`, `PTRACE_GETREGS`, `PTRACE_GETFPREGS`, `PTRACE_SETREGS`, `PTRACE_SETFPREGS`, `PTRACE_CONT`, `PTRACE_SYSCALL`, `PTRACE_SINGLESTEP`, `PTRACE_DETACH`



**追踪正在运行的process**

在上面，child使用`PTRACE_TRACEME`来获得追踪，如果我们需要追踪一个正在运行的process，我们需要使用`PTRACE_ATTACH`。

<u>当`PTRACE_ATTACH`和`pid`一起使用时，约等于process调用了`PTRACE_TRACEME`并且变成了tracer的child</u>。tracee会收到`SIGSTOP`信号，我们在修改完数据之后，需要调用`PTRACE_DETACH`。

`test.c`

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main()
{   int i;
    for(i = 0;i < 10; ++i) {
        printf("My counter: %d\n", i);
        sleep(2);
    }
    return 0;
}
```

`tracer.c`

```c
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/user.h>   /* For user_regs_struct
                             etc. */
#include <sys/reg.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{   pid_t traced_process;
    struct user_regs_struct regs;
    long ins;
    if(argc != 2) {
        // printf("Usage: %s <pid to be traced>\n", argv[0], argv[1]);
        printf("Usage: %s <pid to be traced>\n", argv[0]);
        exit(1);
    }
    traced_process = atoi(argv[1]);
    ptrace(PTRACE_ATTACH, traced_process,
           NULL, NULL);
    wait(NULL);
    ptrace(PTRACE_GETREGS, traced_process,
           NULL, &regs);
    ins = ptrace(PTRACE_PEEKTEXT, traced_process,
                 regs.rip, NULL);
    printf("EIP: %llx Instruction executed: %lx\n",
           regs.rip, ins);
    ptrace(PTRACE_DETACH, traced_process,
           NULL, NULL);
    return 0;
}
```

`tracer`会attach到test，检视它的`eip`（instruction pointer），然后detach。

如果要注入代码，需要在中止tracee之后使用`PTRACE_POKETEXT`，然后`PTRACE_POKEDATA`。



参考链接：

https://www.linuxjournal.com/article/6100