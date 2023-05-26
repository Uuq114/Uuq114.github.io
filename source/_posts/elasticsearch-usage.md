---
title: Elasticsearch 使用记录
tags: [Elasticsearch]
copyright: true
date: 2023-05-26 15:53:26
updated: 2023-05-26 15:53:26
permalink:
categories: [搜索引擎]
description:
---



## 0x00 简介

本文介绍了 ES 在实践上的一些内容，包括：

* ES 中的概念
* 高可用的 ES 集群
* ES 调优的设置项

<!-- more -->

## 0x01 一些名词

首先介绍一些 ES 中的概念：

* Index：ES index 就是一组 shard，这些 shard 分布在多个 node 上，每个 shared 都是一个 self-contained index
* shard：有两种类型，primary 和 replica。replica 可以做备份和查询。primary 的数量在创建索引就确定了，但是 replica 可以在后续调整



## 0x02 高可用

高可用的 ES 集群有三个方面：

* 一个集群内部，可能有节点挂了
* 多个集群，涉及集群之间的复制，follower cluster 可以作为 failover，或者就近提供服务的 geo-replica
* 定期的 snapshot

一个可靠的 ES 集群需要有：

* 至少三个 master 备选的 node
* 每个 role 至少有两个节点
* 每个 shard 至少有两个 copy，primary 和 replica

在剩余的节点上，ES 会自动重建 failed shard，让 health 回到 green。如果要让单节点的 ES 集群健康状态变为 green，需要将 index 的 `index.number_of_replicas`设置为`0`



## 0x03 性能调优

**shard**

要考虑的配置项：primary shard 数量，shard size

* 对于时序类的数据，shard size 一般在 20-40 GB
* 一个 node 可以管理的 shard 数和堆大小有关，1 GB heap 对应 20 个 shard

参考：https://www.elastic.co/guide/en/elasticsearch/reference/current/advanced-configuration.html#set-jvm-heap-size