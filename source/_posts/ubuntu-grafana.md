---
title: 云服务器部署 Grafana 监控记录
tags: [Grafana, Docker]
categories: [数据可视化]
copyright: true
date: 2023-07-19 15:55:33
updated: 2023-07-19 15:55:33
permalink:
description:
---



## 0x00 简介

记录在腾讯云服务器上面配置prometheus+grafana，监视云主机运行状态的过程。

<!-- more -->

## 0x01 整体结构

要部署的服务有prometheus、grafana、node_exporter，前两个在docker中部署，node_exporter因为要采集宿主机的指标信息，所以没有用docker运行。

数据上报的过程是：

node_exporter (9100 port) => prometheus (9090 port) => grafana (3000 port)



## 0x02 

**Docker**

部署比较简单，拉取镜像，指定配置文件映射，再启动容器就ok了。

grafana官方网站有一些dashboard模板，可以通过ID导入，省去了自建dashboard的麻烦。



**效果图**

![image-20230719160454386](image-20230719160454386.png)



## 0x03 其他

因为prometheus和grafana是通过docker启动的，在配置里面要用docker容器的ip

![image-20230719160714202](image-20230719160714202.png)

查询容器的ip：

```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container_name_or_id>
```

