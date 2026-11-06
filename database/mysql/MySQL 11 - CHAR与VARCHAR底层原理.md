---
title: "MySQL 11 - CHAR与VARCHAR底层原理"
date: 2026-07-23
tags: [mysql, innodb, storage-engine, char, varchar, utf8mb4]
source: "鱼皮·编程导航 / codefather"
---

# MySQL 11 - CHAR与VARCHAR底层原理

> MySQL 的 CHAR 在变长字符集（如 UTF8MB4）下并非定长存储，底层实现与 VARCHAR 趋同。

## 核心要点

### CHAR(N) 的 N 指字符个数，非字节

- CHAR(N) 中 N 的范围是 0~255，**指字符个数**，而非字节数
- VARCHAR 和 TEXT 同理按字符个数定义，BINARY/VARBINARY/BLOB 按字节定义

### 字符集影响存储方式

MySQL 通过 `SHOW CHARSET LIKE 'utf8%'` 查看字符集信息：

| Charset | Description   | Maxlen |
|---------|---------------|--------|
| utf8    | UTF-8 Unicode | 3      |
| utf8mb4 | UTF-8 Unicode | 4      |

- `utf8mb4` 是 MySQL 8.0 默认字符集，一个字符对应 1~4 个字节（变长字符集）
- 对于变长字符集，底层存储无法固定每个字符的字节数

> 命令行查看字段字符集：`SHOW CREATE TABLE [表名称];`

### 定长字符遇上变长字节 — InnoDB 的处理

#### Redundant 行格式（旧）

- 仍保持 CHAR(N) 定长存储，长度为 `字符集 Maxlen × N`
- 不足部分用**空格填充**至指定长度
- 查询时尾部空格会被删除（除非启用 `PAD_CHAR_TO_FULL_LENGTH SQL` 模式）

#### Compact 行格式家族（Dynamic / Compressed）— MySQL 8.0 默认

在 InnoDB 的 Compact 行格式家族中，对变长字符集的 CHAR 有特殊优化：

- **CHAR 被当作变长字段**，使用行格式中的「变长字段长度列表」来表达实际字节长度
- 如果实际字节数 ≤ N：存储 N 个字节（而非 Maxlen × N），不额外填充
- 如果实际字节数 > N：不追加空格，按实际存储
- **至少预留 N 个字节空间**，这是为了在大部分情况下实现原地更新，避免索引页分裂

验证实验（utf8mb4，CHAR(5)）：

```sql
CREATE TABLE `char_test` (
  `name` char(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO char_test(name) values ('😊😊😊😊😊');  -- 😊 = F0 9F 98 8A (4 bytes each)
INSERT INTO char_test(name) values ('😊😊😊😊');
```

通过数据文件十六进制查看，CHAR(5) 使用了「变长字段长度列表」记录实际字节数（20 和 16），说明 **CHAR 已被 InnoDB 当作变长字段处理**。

![Dynamic 行格式组成](../image/img_mysql_rowformat_001.png)

### 结论

- **在 MySQL 8.0，使用 InnoDB 引擎及 Dynamic 行格式，且采用变长字符集时，CHAR 底层存储是变长的**
- CHAR 和 VARCHAR 的底层实现在此场景下基本一致
- 有时 CHAR 实际占用空间可能大于 VARCHAR，性能也未必优于 VARCHAR
- **绝大多数场景下，VARCHAR 可以替代 CHAR**

> 来源：鱼皮·编程导航 / codefather
