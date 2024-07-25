---
title: Jane Street Puzzle @ 2023.1
date: 2023-05-14 11:27:39
updated: 2023-05-14 11:27:39
tags: [Puzzle]
categories: [随笔]
description:
copyright: true
---





# 简介

这道题目是 Jane Street 在 2023.1 出的，原文链接在[这里](https://www.janestreet.com/puzzles/lesses-more-index/)。

题目大意是：给定一个四元的数字序列`(a,b,c,d)`，以及序列的变化规则，需要找到经过变换后能变成`(0,0,0,0)`的序列中，变换步数最多同时`a+b+c+d`最小的那个序列。

其中，序列的变化规则形如：
$$
(a,b,c,d) \stackrel{f}{\longrightarrow}
(\lvert a-b \rvert, \lvert b-c \rvert, \lvert c-d \rvert, \lvert d-a \rvert)
$$
最后要找的序列的限制条件是：
$$
\begin{align}
\begin{matrix}
    &(1)& 0 \le a,b,c,d \le 10^7 \\
    &(2)& sum(a+b+c+d) \rightarrow min \\
    &(3)& num(f) \rightarrow max \\
\end{matrix}
\end{align}
$$
定义了特殊情况`f(0,0,0,0)=1`

<!-- more -->

## 解法

设输入序列为`(a,b,c,d)`

注意到满足`a>b>c>d`的序列的变换次数一般会大一些，因为经过`f`变换，大多数的情况都是四个数参差不齐的情况，连续成立的大小关系比较少见，这里就假设`a>b>c>d`了

定义一个归一化处理（记为`N`变换）：
$$
(a,b,c,d) \rightarrow (a-d,b-d,c-d,0) \rightarrow (1,\frac{b-d}{a-d},\frac{c-d}{b-d},0)
$$
上式结果记为`(1,x,y,0)`，按照前面假设的`a>b>c>d`，这里有`1>x>y>0`

要让`f`变换的次数尽量多，每次变换结果的归一化形式就需要尽量接近。最极端的情况是不变，这样就可以无限下去了

在归一化空间中，对`(1,x,y,0)`做`f`变换：
$$
(1,x,y,0) \stackrel{f}{\longrightarrow} (1-x,x-y,y,1) \\
$$
`N`变换需要以四元组最大的数作为约数：（这里四元组可能还有其他的排法）
$$
(1,1-x,x-y,y) \stackrel{N}{\longrightarrow} (1,\frac{1-x-y}{1-y},\frac{x-2y}{1-y},0) \\
或者：
(1,y,x-y,1-x) \stackrel{N}{\longrightarrow} (1,\frac{x+y-1}{x},\frac{2x-y+1}{x},0)
$$
以第一行为例，和开始归一化的`(1,x,y,0)`接近，可以消去`y`得到一个方程：
$$
x^3-4x^2+6x-2=0
$$
解方程可以得到一个`x=0.456311, y=0.160713`

接下来需要用归一化的结果在题目的范围`[1,1e8]`中反推一个初始序列出来，推导过程就省略了

```python
x = 0.8392867552141612
y = 0.5436890126920764

MAX_NUM = 10000000
ERROR = 1e-3


def check(a, b, c):
    d = 0
    cnt = 1
    while True:
        a, b, c, d = abs(a - b), abs(b - c), abs(c - d), abs(d - a)
        cnt += 1
        if a == 0 and b == 0 and c == 0 and d == 0:
            print(f'check({a},{b},{c},0) is true, count: {cnt}')
            break
        elif cnt >= 1000:
            break


def find():
    for i in range(MAX_NUM):
        # print(i)
        first = x * i
        second = y * i
        if abs(int(first) - first) <= ERROR and abs(int(second) - second) <= ERROR:
            print(f'i, first, second: {i}, {first}, {second}')
            check(i, int(first), int(second))


if __name__ == '__main__':
    find()
    print('---')
    check(8646064, 3945294, 1389537)
```

最后可以得到结果了：`(8646064, 3945294, 1389537, 0)`