---
title: "Linux 06 - 服务管理与systemd"
date: 2026-06-11
tags: [os, linux]
---

# Linux 06 - 服务管理与systemd

## systemctl 命令

```bash
# 服务生命周期
sudo systemctl start nginx      # 启动
sudo systemctl stop nginx       # 停止
sudo systemctl restart nginx    # 重启
sudo systemctl reload nginx     # 重载配置（不中断）
sudo systemctl status nginx     # 查看状态

# 开机自启
sudo systemctl enable nginx     # 开机自启
sudo systemctl disable nginx    # 关闭自启
sudo systemctl is-enabled nginx # 检查是否自启

# 列出
sudo systemctl list-units --type=service     # 运行中服务
sudo systemctl list-units --type=service --all # 所有服务
sudo systemctl list-unit-files | grep nginx   # 查看是否 enable
```

## systemd service 单元文件

### 自定义服务示例：`/etc/systemd/system/myapp.service`

```ini
[Unit]
Description=My Application Service
After=network.target mysql.service
Requires=mysql.service

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/myapp
ExecStart=/usr/local/bin/myapp server
ExecStop=/usr/local/bin/myapp stop
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
Environment=GIN_MODE=release
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

### 单元文件路径

| 路径 | 优先级 |
|------|--------|
| `/etc/systemd/system/` | 最高（用户自定义） |
| `/usr/lib/systemd/system/` | 默认（包管理器安装） |

### Type 类型

| 类型 | 说明 |
|------|------|
| `simple` | 默认，进程不 fork |
| `forking` | 进程 fork 到后台（需指定 PIDFile） |
| `oneshot` | 执行一次就退出 |
| `notify` | 进程启动后发通知 sd_notify() |

## journalctl 日志管理

```bash
journalctl -u nginx            # 查看服务日志
journalctl -u nginx -n 100     # 最近 100 行
journalctl -u nginx -f         # 实时跟踪
journalctl --since "1 hour ago"
journalctl -u nginx -p err     # 仅错误级别

# 日志持久化
# /var/log/journal/ 保留重启后日志
sudo mkdir -p /var/log/journal
```

## 定时任务

```bash
# crontab 格式
# 分 时 日 月 周  命令
  0  2  *  *  *  /usr/bin/backup.sh

# 编辑
crontab -e
crontab -l    # 查看

# 常用示例
*/5 * * * *   /script/healthcheck.sh    # 每 5 分钟
0 3 * * 1     /script/weekly-report.sh  # 每周一 3:00
@reboot       /script/on-startup.sh     # 开机执行
```
