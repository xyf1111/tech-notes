---
title: 中间件 - Canal 增量同步
date: 2026-07-28
tags:
  - canal
  - 数据同步
  - mysql
  - binlog
  - 中间件
source: "鱼皮·编程导航 / codefather"
---

# Canal 增量同步

> Canal 是阿里开源的数据同步框架，基于 MySQL binlog 日志实现增量订阅和消费，用于实时数据同步、数据库镜像、缓存刷新等场景。

## 核心原理

### MySQL 主备复制原理

1. MySQL master 将数据变更写入二进制日志（binary log / binlog events，可通过 `show binlog events` 查看）
2. MySQL slave 将 master 的 binary log events 拷贝到中继日志（relay log）
3. MySQL slave 重放 relay log 中的事件，将数据变更反映到自身数据

### Canal 工作原理

Canal 模拟 MySQL slave 的交互协议，伪装自己为 slave，向 master 发送 dump 协议。master 收到请求后推送 binary log 给 canal，canal 解析 binary log 对象（原始 byte 流），实现增量数据消费。

### 支持版本

源端 MySQL 版本包括 5.1.x、5.5.x、5.6.x、5.7.x、8.0.x。

### 应用场景

- 数据库镜像
- 数据库实时备份
- 索引构建和实时维护（拆分异构索引、倒排索引等）
- 业务缓存刷新
- 带业务逻辑的增量数据处理

## 环境搭建

### 开启 binlog 日志

检查当前 binlog 状态：

```bash
mysql -uroot -p
show variables like 'log_%';
```

若 `log_bin` 为 OFF，修改 MySQL 配置文件 `/etc/my.cnf`：

```ini
log-bin=mysql-bin     # binlog 文件名
binlog_format=ROW     # 必须使用 ROW 模式
server_id=1          # MySQL 实例 ID，不能与 canal 的 slaveId 重复
```

重启 MySQL：

```bash
service mysql restart
```

### 创建 canal 用户

```sql
-- 修改密码校验规则（可选）
set global validate_password_length=0;
set global validate_password_policy=LOW;

-- 创建用户
CREATE USER canal IDENTIFIED BY 'canal';

-- 授权（需包含 REPLICATION SLAVE、REPLICATION CLIENT）
GRANT SELECT, UPDATE, INSERT, DELETE, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%';
FLUSH PRIVILEGES;
```

### Canal 服务端配置

配置文件 `conf/example/instance.properties`：

```properties
# 数据库连接
canal.instance.master.address=192.168.44.132:3306
canal.instance.dbUsername=root
canal.instance.dbpassword=root

# 同步表规则
canal.instance.filter.regex=.*\\..*
```

**正则规则说明：**

- 所有表：`.*` 或 `.*\\..*`
- 库下所有表：`canal\\..*`
- 库下以 canal 打头的表：`canal\\.canal.*`
- 库下单表：`canal.test1`
- 多个规则用逗号（,）分隔
- 转义符需要双斜杠
- **注意**：过滤条件只对 ROW 模式有效（mixed/statement 模式不解析 SQL）

### 启动 Canal

```bash
# 进入 bin 目录
sh bin/startup.sh
```

## Spring Boot 集成

### Maven 依赖

```xml
<dependencies>
    <dependency>
        <groupId>com.alibaba.otter</groupId>
        <artifactId>canal.client</artifactId>
    </dependency>
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
    </dependency>
    <dependency>
        <groupId>commons-dbutils</groupId>
        <artifactId>commons-dbutils</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-jdbc</artifactId>
    </dependency>
</dependencies>
```

### 应用配置

```properties
server.port=10001
spring.application.name=canal-client
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.url=jdbc:mysql://localhost:3306/test?useUnicode=true&characterEncoding=utf-8
```

### 客户端核心代码

#### 连接与订阅

```java
@Component
public class CanalClient {

    private Queue<String> SQL_QUEUE = new ConcurrentLinkedQueue<>();

    @Resource
    private DataSource dataSource;

    public void run() {
        CanalConnector connector = CanalConnectors.newSingleConnector(
            new InetSocketAddress("192.168.61.111", 11111), "example", "", "");
        int batchSize = 1000;
        try {
            connector.connect();
            connector.subscribe(".*\\..*");
            connector.rollback();
            while (true) {
                Message message = connector.getWithoutAck(batchSize);
                long batchId = message.getId();
                int size = message.getEntries().size();
                if (batchId == -1 || size == 0) {
                    Thread.sleep(1000);
                } else {
                    dataHandle(message.getEntries());
                }
                connector.ack(batchId);
                if (SQL_QUEUE.size() >= 1) {
                    executeQueueSql();
                }
            }
        } finally {
            connector.disconnect();
        }
    }
}
```

#### 事件分发（INSERT / UPDATE / DELETE 解析）

```java
private void dataHandle(List<CanalEntry.Entry> entrys) {
    for (CanalEntry.Entry entry : entrys) {
        if (EntryType.ROWDATA == entry.getEntryType()) {
            RowChange rowChange = RowChange.parseFrom(entry.getStoreValue());
            CanalEntry.EventType eventType = rowChange.getEventType();
            if (eventType == EventType.DELETE) {
                saveDeleteSql(entry);
            } else if (eventType == EventType.UPDATE) {
                saveUpdateSql(entry);
            } else if (eventType == CanalEntry.EventType.INSERT) {
                saveInsertSql(entry);
            }
        }
    }
}
```

#### INSERT 语句构造

```java
private void saveInsertSql(CanalEntry.Entry entry) {
    RowChange rowChange = CanalEntry.RowChange.parseFrom(entry.getStoreValue());
    List<CanalEntry.RowData> rowDatasList = rowChange.getRowDatasList();
    for (RowData rowData : rowDatasList) {
        List<CanalEntry.Column> columnList = rowData.getAfterColumnsList();
        StringBuffer sql = new StringBuffer(
            "insert into " + entry.getHeader().getTableName() + " (");
        for (int i = 0; i < columnList.size(); i++) {
            sql.append(columnList.get(i).getName());
            if (i != columnList.size() - 1) sql.append(",");
        }
        sql.append(") VALUES (");
        for (int i = 0; i < columnList.size(); i++) {
            sql.append("'" + columnList.get(i).getValue() + "'");
            if (i != columnList.size() - 1) sql.append(",");
        }
        sql.append(")");
        SQL_QUEUE.add(sql.toString());
    }
}
```

#### UPDATE 语句构造

```java
private void saveUpdateSql(CanalEntry.Entry entry) {
    RowChange rowChange = RowChange.parseFrom(entry.getStoreValue());
    List<RowData> rowDatasList = rowChange.getRowDatasList();
    for (RowData rowData : rowDatasList) {
        List<CanalEntry.Column> newColumnList = rowData.getAfterColumnsList();
        StringBuffer sql = new StringBuffer(
            "update " + entry.getHeader().getTableName() + " set ");
        for (int i = 0; i < newColumnList.size(); i++) {
            sql.append(newColumnList.get(i).getName() + " = '"
                + newColumnList.get(i).getValue() + "'");
            if (i != newColumnList.size() - 1) sql.append(",");
        }
        sql.append(" where ");
        List<CanalEntry.Column> oldColumnList = rowData.getBeforeColumnsList();
        for (CanalEntry.Column column : oldColumnList) {
            if (column.getIsKey()) {
                sql.append(column.getName() + "=" + column.getValue());
                break;  // 仅支持单一主键
            }
        }
        SQL_QUEUE.add(sql.toString());
    }
}
```

#### DELETE 语句构造

```java
private void saveDeleteSql(CanalEntry.Entry entry) {
    RowChange rowChange = RowChange.parseFrom(entry.getStoreValue());
    List<RowData> rowDatasList = rowChange.getRowDatasList();
    for (RowData rowData : rowDatasList) {
        List<CanalEntry.Column> columnList = rowData.getBeforeColumnsList();
        StringBuffer sql = new StringBuffer(
            "delete from " + entry.getHeader().getTableName() + " where ");
        for (CanalEntry.Column column : columnList) {
            if (column.getIsKey()) {
                sql.append(column.getName() + "=" + column.getValue());
                break;  // 仅支持单一主键
            }
        }
        SQL_QUEUE.add(sql.toString());
    }
}
```

#### SQL 执行入库

```java
public void execute(String sql) {
    if (null == sql) return;
    Connection con = dataSource.getConnection();
    QueryRunner qr = new QueryRunner();
    int row = qr.execute(con, sql);
    System.out.println("update: " + row);
}
```

## 说明

- 上述 client 代码在内存中维护 SQL 队列，当队列积压时批量执行，适用于简单的数据同步场景
- 生产环境通常结合 Kafka 和 ZooKeeper 实现多节点注册和分布式数据处理
- Canal 基于 binlog 增量同步，不侵入业务系统，对主库影响极小

> 来源：鱼皮·编程导航 / codefather
