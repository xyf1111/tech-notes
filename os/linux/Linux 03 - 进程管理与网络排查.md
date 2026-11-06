---
title: "Linux 03 - 进程管理与网络排查"
date: 2024-01-01
tags: [Linux]
---

# Linux 03 - 进程管理与网络排查

## 进程管理

```bash
# 查看进程
ps aux                    # 所有进程
ps -ef                    # 标准格式
top                       # 实时进程监控（按 P=CPU, M=内存, q=退出）
htop                      # 增强版 top（推荐）

# 查找进程
pgrep -u user nginx       # 查找用户下的 nginx 进程
pidof nginx               # 查找 nginx 的 PID

# 杀死进程
kill PID                  # 默认 SIGTERM（15）
kill -9 PID               # SIGKILL（强制杀）
kill -15 PID              # SIGTERM（优雅终止）
pkill -f "process_name"   # 按名字杀
pkill -u user             # 杀某用户的所有进程
```

### 后台运行

```bash
# 后台运行
nohup command > output.log 2>&1 &
# 或使用 screen/tmux
screen -S session_name
tmux new -s session_name
```

### 强制终止进程的后果（为什么别随意 kill -9）

进程被强制中断（kill -9、断电、系统崩溃）除了服务不可用，还会引发一系列隐患：

1. **请求丢失**：Web 服务器（如 Tomcat）等待队列中排队的请求全部丢失
2. **业务中断**：正在执行的业务卡在中间状态（如检查任务把数据状态置 1 后中断，该数据永远不再被检查）
3. **事务中断**：转账扣款成功但入账未完成 → 数据不一致，还可能锁行锁表影响可用性
4. **文件损坏**：正在写入的文件不完整甚至损坏
5. **任务丢失**：线程池队列中尚未执行的任务消失，如同从未提交
6. **数据丢失**：内存中未持久化的数据丢失（如 Redis RDB 快照间隔内的数据）
7. **消息丢失**：① 待发送的应答消息未发出，客户端重试导致重复处理；② 消息处理完未确认，队列阻塞或无限重发
8. **资源占用**：内存未回收、临时文件残留、端口未释放、连接未关闭
9. **服务未下线**：注册中心（如 Eureka）仍保留路由，消费者调用失败，严重时引发雪崩

分布式场景影响更大（数据一致性），正如 FLP 不可能定理：异步通信下即使只有一个进程失败，也无法保证所有非失败进程达到一致性。**预防大于治疗**：线上用优雅停机（SIGTERM 处理完当前请求再退出），程序设计时做好数据监控、任务补偿与持久化兜底，避免强制停机后「看不见的危险」。

## 系统资源

```bash
# CPU
lscpu                     # CPU 信息
cat /proc/cpuinfo         # 详细 CPU 信息
uptime                    # 系统负载（1m/5m/15m）

# 内存
free -h                   # 内存使用
cat /proc/meminfo

# 磁盘
iostat -x 1               # 磁盘 I/O（需 sysstat）
iotop                     # 进程级 I/O 监控

# 网络
ss -tuln                  # 监听端口（代替 netstat）
ss -tup                   # 已建立的连接
netstat -an               # 所有连接（需安装 net-tools）
```

## 网络排查命令

```bash
# DNS
nslookup example.com
dig example.com

# 连通性
ping -c 4 example.com
traceroute example.com       # 路由追踪

# HTTP 调试
curl -v http://example.com   # 完整请求/响应
curl -I https://example.com  # 仅响应头

# socket 统计
ss -s                        # socket 统计
```

### 排查思路

```bash
# 1. 端口是否监听
ss -tuln | grep 8080

# 2. 防火墙是否放行
iptables -L -n               # Linux 防火墙
ufw status                   # Ubuntu 防火墙

# 3. 服务状态
systemctl status nginx
journalctl -u nginx -n 50    # 查看服务日志最近 50 行

# 4. 资源瓶颈
# CPU：top 按 P 排序
# 内存：free -h
# 磁盘：df -h, iostat -x
# 网络：iftop, nethogs
```

### 服务器无法访问排查（7 步清单）

> 服务器没挂但访问不了端口？从应用层到用户侧按 7 步逐一排查。

1. **应用程序未启动**——最低级也最常见的错误：
   ```bash
   ps aux | grep <项目名>
   ```
   宝塔面板陷阱：项目刚启动显示「运行中」，系统异常几秒后就变「未启动」——以 `ps` 实际进程为准

2. **端口监听错误**——项目要监听正确端口：
   ```bash
   netstat -ntlp | grep <端口号>
   ```
   输出 `:::8104` 和 `:::*` 表示程序监听在所有 IPv4 地址的 8104 端口、允许所有来源 IP 连接；若是其他值则远程无法访问，需调整应用的启动端口配置

3. **云服务商安全组**——在哪家服务商买的服务器，就进对应后台的安全组设置界面，放行指定来源的流量通过端口；来源 `0.0.0.0/0` = 允许所有用户（建议谨慎），学习用可改为自己家 IP、只允许自己访问

4. **服务器防火墙**——Linux 内置防火墙也要放行（不同发行版命令可能不同，以下是 Ubuntu 的）：
   ```bash
   # 查看防火墙状态（两种方式均可）
   sudo iptables -L
   sudo systemctl status firewalld
   # 应急关闭（一般不建议）
   sudo systemctl stop firewalld
   sudo systemctl disable firewalld
   ```

5. **应用层限制**——宝塔安全/防火墙面板、Nginx 或业务代码都可能对访问 IP 做限制；这些是常用安全策略，别把正常用户也限制了

6. **服务器网络问题**——极端情况：服务器突然断网、或网络配置被改错，用连通性检测：
   ```bash
   ping <服务器地址>
   traceroute <服务器地址>
   ```

7. **用户自身问题**——最难排查的一类：用户本地网络断了、或服务器禁用了海外 IP（部分用户能访问、部分不能）——真实案例：用户报「网站访问不了」，排查半天发现是自己家断网；另一案例切换网络后即恢复正常

## 日志查看

```bash
# 实时跟踪
tail -f /var/log/nginx/access.log

# 搜索
grep "ERROR" /var/log/app.log
grep -c "timeout" /var/log/app.log

# journalctl（systemd 日志）
journalctl -xe                  # 最近的错误
journalctl -f                   # 实时跟踪
journalctl -u nginx --since today
```
