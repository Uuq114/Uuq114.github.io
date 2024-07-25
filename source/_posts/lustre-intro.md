---
title: Lustre 101
tags: [Lustre]
categories: [文件系统]
copyright: true
date: 2023-07-27 20:45:09
updated: 2023-07-27 20:45:09
permalink:
description:
---



## 0x00 Lustre Intro

This post is a brief introduction to Lustre, an open-source distributed clustered file system.

<!-- more -->

## 0x01 Architecture

Lustre architecture

<img src="lustre-arch.png" alt="未命名文件" style="zoom:60%;" />

* 元数据服务器（metadata server，MDS）：一个Lustre文件系统通常拥有两个元数据服务器（active和standby），一个元数据服务器则拥有若干元数据目标（metadata targets，MDTs）。元数据目标存储命名空间元数据：文件名、目录、访问权限、文件结构等信息。不同于诸如GPFS和PanFS等基于块并由元数据服务器控制所有块分配的分布式文件系统，Lustre元数据服务器仅仅关心路径搜索和权限检查而不会牵涉任何的文件I/O操作。该特性避免元数据服务器成为集群扩展的瓶颈。
* 对象存储服务器（object storage server，OSS）将文件数据存储于一个或多个对象存储目标（object storage target，OST）中。取决于服务器硬件，一个对象存储服务器通常有二到八个对象存储目标，每个对象存储目标管理一个本地文件系统。Lustre文件系统的空间等于所有对象存储目标的容量总和。
* 客户机（Clients）能访问并使用数据。Lustre为所有客户机提供统一的命名空间。



## 0x02 Network

lustre是基于RPC的，下面是整个RPC stack。LNet是自己做flow control的

```
Node-specific lustre code
=========================
portal RPC
=========================
LNet(lustre networking)
=========================
LND(lustre network driver), o2iblnd(OFED 2nd IB LND)
=========================
OFED
```

