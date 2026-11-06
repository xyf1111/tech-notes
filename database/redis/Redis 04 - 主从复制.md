---
title: "Redis 04 - 主从复制"
date: 2021-03-15
tags: [redis]
aliases:
  - "Redis Study 04"
---

# Redis 04 - 主从复制


## Redis主从复制


### 概念


主从复制，是指将一台Redis服务器的数据，复制到其他的Redis服务器。前者称为主节点（master/leader），后者称为从节点（slave/follower）。数据的复制是单向的，只能从主节点到从节点。master以写为主，salve以读为主。


默认情况下，每台Redis服务器都是主节点。且每个主节点可以有多个从节点（或没有从节点），但是一个从节点只能有一个主节点


主从复制包括：


1. 数据冗余：主从复制实现了数据的热备份，是持久化的一种数据冗余方式
2. 故障修复：当主节点出现问题，可以由从节点提供服务，实现快速的故障修复，实际上是一种服务的冗余
3. 负载均衡：在主从复制的基础上，配合读写分离，可以由主节点提供写服务，从节点提供读服务（即写Redis数据时应用连接主节点，读Redis数据是应用连接从节点），分担服务器负载；尤其在写少读多的情况下，通过多个节点分担读负载，可以大大提高Redis服务的并发量
4. 高可用（集群）基石：除了上述作用以外，主从复制还是哨兵和集群能够实施的基础，因此说主从复制是Redis的高可用的基础。
一般来说，要将Redis运用于工程项目中，只使用一台Redis是万万不能的，原因如下：
5. 从结构上，单个Redis服务器会发生单点故障，并且一台服务器要处理所有的请求负载，压力较大。
6. 从容量上，单个Redis服务器内存容量有限，就算一台Redis服务器内存容量为256GB，也不能将所有内存作为Redis存储内存，一般来说，单台Redis最大使用内存不应该超过20GB
一般电商网站上的商品，一般都是一次上传，无数次浏览，说专业点就是多读少写


主从复制，读写分离！80%的情况下都是在进行读操作！减缓服务器压力！架构中经常使用一主二从！


### 环境配置


只配置从库，不用配置主库


```bash
127.0.0.1:6379> info replication    #   查看当前库的信息

# Replication
role:master # 角色
connected_slaves:0  #   连接的从机个数
master_replid:c3d733dbffb09746cf8ef0b4b87ce62406dd0c83
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:0
second_repl_offset:-1
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
```

复制3个配置文件，然后修改对应的配置信息


1. 端口号
2. pid文件名
3. 日志名
4. dump.rdb文件
修改完毕后启动，启动3个Redis集群

![redis主从复制配置](https://xyf1111.github.io/images/redis-conf3.png)
*redis主从复制配置*


### 一主二从


默认情况下，每台Redis服务器都是主节点；我们一般情况下只要配置从机就可以了


```bash
127.0.0.1:6380> SLAVEOF 127.0.0.1 6379  # 选择主机
OK
127.0.0.1:6380> info replication

# Replication
role:slave  #   当前角色是从机
master_host:127.0.0.1   #   主机ip
master_port:6379        #   主机端口号
master_link_status:up
master_last_io_seconds_ago:2
master_sync_in_progress:0
slave_repl_offset:14
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:60116b0ccf67baa49701e78ea9cbb17c2673dded
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:14
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:14

#   配置完两台从机
127.0.0.1:6379> info replication

# Replication
role:master
connected_slaves:2
slave0:ip=127.0.0.1,port=6380,state=online,offset=1148,lag=0
slave1:ip=127.0.0.1,port=6381,state=online,offset=1148,lag=0
master_replid:60116b0ccf67baa49701e78ea9cbb17c2673dded
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:1148
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:1148
```

真实的从主配置应该在配置文件中，这样的话是永久的，这里使用命令配置，暂时的。


主机可以写，从机不能写只能读！主机中的所有信息都会被从机自动保存


主机断开连接，从机依旧可以连到主机，但没有写操作。如果主机重新连接了，从机依旧可以直接获取主机写的信息!


如果使用命令行配置主从，如果从机重启了，就会变回主机！只要变回从机，就能立马从主机获取值

> Redis 5.0 起 `SLAVEOF` 更名为 `REPLICAOF`（旧命令仍兼容），配置文件中的 `slaveof` 对应 `replicaof`。

### 复制原理（全量同步与增量同步）

从节点向主节点发送 `PSYNC <runid> <offset>` 发起同步：

- `runid`：主节点运行 ID。从节点第一次同步不知道主节点 ID，传 `"?"`。
- `offset`：复制进度偏移量，第一次同步传 `-1`。

主节点据此决定走**全量同步**还是**增量同步**。

#### 全量同步（首次连接 / 断连过久）

1. 从节点发送 `psync ? -1`；
2. 主节点发现 runid 无效，判定为全量同步，返回 `+FULLRESYNC <runid> <offset>`，从节点保存这两个值；
3. 主节点执行 `bgsave` 生成 RDB 快照；生成期间新收到的写命令缓存到 `replication buffer`；
4. RDB 生成完毕后发送给从节点，从节点**先清空旧数据**再加载 RDB；
5. 从节点加载完成后，主节点把 `replication buffer` 中积压的写命令发过去重放，达到一致；
6. 之后主从保持长连接，主节点持续把写命令传播给从节点（命令传播阶段）。

#### 增量同步（断线重连）

网络抖动导致断连时，若再走全量同步代价太大，因此 Redis 2.8 引入 `PSYNC` 做部分重同步。

- `repl_backlog_buffer` 是主节点上的**环形缓冲区**（默认 1MB），保存最近的写命令；
- 从节点重连后带上自己记录的 `runid` + `offset`；
- 主节点校验：runid 与自己一致，且 offset 之后的数据仍在 backlog 中 → 只把 offset 之后的命令写入 `replication buffer` 发送，从节点执行即完成增量同步；
- 若 offset 已被环形写入覆盖 → 只能退回全量同步。因此线上通常调大 `repl_backlog_size`，尽量避免全量复制。

#### replication buffer 与 repl_backlog_buffer 的区别

| 维度 | `replication buffer` | `repl_backlog_buffer` |
|------|---------------------|----------------------|
| 数量 | 每个从节点一个（主节点为每个 slave 单独创建） | 主节点全局一个 |
| 作用 | 全量同步期间缓存 RDB 生成过程中的写命令；实时传输写命令给对应从节点 | 保存最近的写命令，供断线重连时做部分重同步 |
| 大小 | 动态增长，无明确上限 | 固定环形大小，默认 1MB，写满后覆盖旧数据 |
| 控制参数 | `client-output-buffer-limit`（间接限制） | `repl-backlog-size` |

`replication buffer` 超限会直接断开连接，例如：

```bash
client-output-buffer-limit slave 256mb 64mb 60
```

表示从节点输出缓冲区超过 256MB，或超过 64MB 持续 60 秒，Redis 就断开该从节点连接（从节点对主节点而言也是一个客户端）。同步速度慢的从节点需要更大的缓冲，这也是主节点内存可能被复制拖垮的常见原因。