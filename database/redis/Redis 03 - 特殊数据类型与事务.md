---
title: "Redis 03 - 特殊数据类型与事务"
date: 2021-03-15
tags: [redis]
aliases:
  - "Redis Study 03"
---

# Redis Study 03


## 三大特殊数据类型


### geospatial（地理位置）


Redis的GEO


```bash
#######################################################

#   geoadd  添加geo

#   geopos  获取geo
127.0.0.1:6379> GEOADD china:city 116.40 39.90 beijing
(integer) 1
127.0.0.1:6379> GEOADD china:city 121.47 31.23 shanghai 106.50 29.53 chongqin
(integer) 2
127.0.0.1:6379> GEOADD china:city 120.16 30.24 hangzhou 108.96 34.26 xian
(integer) 2
127.0.0.1:6379> GEOPOS china:city beijing chongqin
1) 1) "116.39999896287918091"
   2) "39.90000009167092543"
2) 1) "106.49999767541885376"
   2) "29.52999957900659211"
#######################################################

#   geodist 两点之间的距离
127.0.0.1:6379> GEODIST china:city beijing shanghai km  # 查看北京到上海的距离
"1067.3788"
#######################################################

#   georadius 获取坐标点周围的数据
127.0.0.1:6379> GEORADIUS china:city 110 30 1000 km # 获取坐标点位110,30方圆1000km在china:city数据
1) "chongqin"
2) "xian"
3) "hangzhou"
127.0.0.1:6379> GEORADIUS china:city 110 30 500 km
1) "chongqin"
2) "xian"
#######################################################

#   georadiusbymember   以城市为中心方圆的数据
127.0.0.1:6379> GEORADIUSBYMEMBER china:city beijing 100 km
1) "beijing"
127.0.0.1:6379> GEORADIUSBYMEMBER china:city beijing 1000 km
1) "beijing"
2) "xian"
127.0.0.1:6379> GEORADIUSBYMEMBER china:city hanghai 1000 km
(error) ERR could not decode requested zset member
127.0.0.1:6379> GEORADIUSBYMEMBER china:city shanghai 1000 km
1) "hangzhou"
2) "shanghai"
#######################################################

#   geohash 以hash返回数据的经纬度
127.0.0.1:6379> GEOHASH china:city beijing
1) "wx4fbxxfke0"
#######################################################

#   geo底层实现原理其实是zset
127.0.0.1:6379> ZRANGE china:city 0 -1  #   查看全部元素
1) "chongqin"
2) "xian"
3) "hangzhou"
4) "shanghai"
5) "beijing"
127.0.0.1:6379> ZREM china:city beijing #   移除元素
(integer) 1
127.0.0.1:6379> ZRANGE china:city 0 -1
1) "chongqin"
2) "xian"
3) "hangzhou"
4) "shanghai"
```

## Spring Boot 集成 GEO 实战

将 Redis GEO 应用于伙伴匹配项目，实现用户间距离计算和搜索附近用户功能。

### 数据模型设计

用户表添加经纬度字段：

```sql
-- 在 user 表追加两个字段
longitude    decimal(10, 6)     null comment '经度',
dimension    decimal(10, 6)     null comment '纬度'
```

UserVO 添加 `distance` 字段，向前端返回用户间的距离：

```java
@Data
public class UserVO {
    // ... 其他字段
    private Double distance;   // 用户距离，单位 km
}
```

### 导入用户地理数据到 Redis

使用 `StringRedisTemplate.opsForGeo().add()` 批量导入。底层用 ZSET 存储，value=用户ID，score=经纬度编码。

```java
@Test
public void importUserGEOByRedis() {
    List<User> userList = userService.list();
    String key = RedisConstant.USER_GEO_KEY;
    List<RedisGeoCommands.GeoLocation<String>> locationList = new ArrayList<>(userList.size());
    for (User user : userList) {
        locationList.add(new RedisGeoCommands.GeoLocation<>(
            String.valueOf(user.getId()),
            new Point(user.getLongitude(), user.getDimension())));
    }
    stringRedisTemplate.opsForGeo().add(key, locationList);
}
```

### 计算用户间距离

```java
Distance distance = stringRedisTemplate.opsForGeo()
    .distance(key, "1", String.valueOf(user.getId()),
              RedisGeoCommands.DistanceUnit.KILOMETERS);
```

### 搜索附近用户

`opsForGeo().radius(key, circle, args)` — Circle 由圆心（目标经纬度）和半径（搜索距离）构成，注意排除自身。

```java
@Test
public void searchUserByGeo() {
    User loginUser = userService.getById(1);
    // 定义圆心与半径
    Distance geoRadius = new Distance(1500, RedisGeoCommands.DistanceUnit.KILOMETERS);
    Circle circle = new Circle(
        new Point(loginUser.getLongitude(), loginUser.getDimension()), geoRadius);

    GeoRadiusCommandArgs args = GeoRadiusCommandArgs.newGeoRadiusArgs().includeCoordinates();
    GeoResults<RedisGeoCommands.GeoLocation<String>> results =
        stringRedisTemplate.opsForGeo().radius(USER_GEO_KEY, circle, args);

    for (GeoResult<RedisGeoCommands.GeoLocation<String>> result : results) {
        // 排除自身
        if (!result.getContent().getName().equals("1")) {
            System.out.println(result.getContent().getName());
        }
    }
}
```

### 与推荐/匹配系统集成

**推荐接口**：分页查询用户后，对每个用户计算距离并设置到 UserVO.distance：

```java
@GetMapping("/recommend")
public BaseResponse<List<UserVO>> recommendUsers(long pageSize, long pageNum, HttpServletRequest request) {
    User loginUser = userService.getLoginUser(request);
    // 分页查询
    IPage<User> page = new Page<>(pageNum, pageSize);
    IPage<User> userIPage = userService.page(page, new QueryWrapper<User>()
        .ne("id", loginUser.getId()));

    List<UserVO> userVOList = userIPage.getRecords().stream().map(user -> {
        Distance distance = stringRedisTemplate.opsForGeo()
            .distance(GEO_KEY, String.valueOf(loginUser.getId()),
                      String.valueOf(user.getId()), DistanceUnit.KILOMETERS);
        UserVO userVO = new UserVO();
        BeanUtils.copyProperties(user, userVO);   // 省略重复 setter
        userVO.setDistance(distance.getValue());
        return userVO;
    }).collect(Collectors.toList());
    return ResultUtils.success(userVOList);
}
```

**匹配接口**：基于标签编辑距离排序后，补充距离字段：

```java
@Override
public List<UserVO> matchUsers(long num, User loginUser) {
    // 1. 标签编辑距离排序（省略篇幅，见匹配算法）
    // 2. 对最终匹配用户列表补充距离
    List<UserVO> finalUserVOList = finalUserList.stream().map(user -> {
        Distance distance = stringRedisTemplate.opsForGeo()
            .distance(GEO_KEY, String.valueOf(loginUser.getId()),
                      String.valueOf(user.getId()), DistanceUnit.KILOMETERS);
        UserVO userVO = new UserVO();
        BeanUtils.copyProperties(user, userVO);
        userVO.setDistance(distance.getValue());
        return userVO;
    }).collect(Collectors.toList());
    return finalUserVOList;
}
```

**搜索附近接口**：单独实现，仅返回半径内的用户：

```java
@Override
public List<UserVO> searchNearby(int radius, User loginUser) {
    String geoKey = RedisConstant.USER_GEO_KEY;
    String userId = String.valueOf(loginUser.getId());
    // 以登录用户为圆心
    Circle circle = new Circle(
        new Point(loginUser.getLongitude(), loginUser.getDimension()),
        new Distance(radius, RedisGeoCommands.DistanceUnit.KILOMETERS));

    GeoResults<RedisGeoCommands.GeoLocation<String>> results =
        stringRedisTemplate.opsForGeo().radius(geoKey, circle);

    List<Long> userIdList = new ArrayList<>();
    for (GeoResult<RedisGeoCommands.GeoLocation<String>> result : results) {
        if (!userId.equals(result.getContent().getName())) {
            userIdList.add(Long.parseLong(result.getContent().getName()));
        }
    }
    return userIdList.stream().map(id -> {
        User user = this.getById(id);
        UserVO userVO = new UserVO();
        BeanUtils.copyProperties(user, userVO);
        Distance distance = stringRedisTemplate.opsForGeo()
            .distance(geoKey, userId, String.valueOf(id), DistanceUnit.KILOMETERS);
        userVO.setDistance(distance.getValue());
        return userVO;
    }).collect(Collectors.toList());
}
```

> 来源：鱼皮·编程导航 / codefather

### hyperloglog


基数：一个set不重复元素的数量
hyperloglog主要用来做统计
如果可以容错可以使用这个。这个空间占用少。


```bash
#######################################################

#   pfadd   添加元素

#   pfcount 获得元素个数

#   pfmerge 将两个set整合到一个新的集合
127.0.0.1:6379> PFADD myset a b c d e f g h i j k
(integer) 1
127.0.0.1:6379> PFCOUNT myset
(integer) 11
127.0.0.1:6379> PFADD myset2 b s d j o l m n u
(integer) 1
127.0.0.1:6379> PFCOUNT myset2
(integer) 9
127.0.0.1:6379> PFMERGE myset3 myset myset2
OK
127.0.0.1:6379> PFCOUNT myset3
(integer) 17
```

#### UV/PV 统计应用

- **UV（Unique Visitor）**：独立访客量，同一用户一天内多次访问只计 1 次
- **PV（Page View）**：页面访问量/点击量，每次打开页面计 1 次
- PV/UV 比值可衡量网站用户粘度

HyperLogLog 适合 UV 统计场景，原因：
- 内存占用极低（单键 **<16KB**），即便存储百万级维度的数据
- 统计结果存在 **<0.81%** 的概率误差，对 UV 统计可忽略
- 自动去重：`PFADD` 添加时自动去除重复元素

Java（Spring Boot）操作示例：

```java
// 模拟 100 万用户访问
String[] users = new String[1000];
int index = 0;
for (int i = 0; i < 1000000; i++) {
    users[index++] = "user_" + i;
    if (i % 1000 == 0) {
        index = 0;
        redisTemplate.opsForHyperLogLog().add("test", users);
    }
}
// 统计数量
Long size = redisTemplate.opsForHyperLogLog().size("test");
System.out.println("size=" + size);  // 约 999xxx，接近 100 万
```

### bitmaps


位存储
只有存储0和1


```bash
#######################################################

#   setbit  添加数据

#   getbit  获得数据

#   bitcount    统计个数
127.0.0.1:6379> SETBIT sign 0 1
(integer) 0
127.0.0.1:6379> SETBIT sign 1 1
(integer) 0
127.0.0.1:6379> SETBIT sign 2 0
(integer) 0
127.0.0.1:6379> SETBIT sign 3 0
(integer) 0
127.0.0.1:6379> SETBIT sign 4 1
(integer) 0
127.0.0.1:6379> GETBIT sign 3
(integer) 0
127.0.0.1:6379> GETBIT sign 4
(integer) 1
127.0.0.1:6379> BITCOUNT sign
(integer) 3
```

## 事务


Redis事务本质：一组命令的集合。一个事务中的所有命令会被序列化，在事务执行的过程中，会按顺序执行。


一次性、顺序性、排他性。执行一些命令


Redis单条命令保持原子性，事务不保证原子性


Redis事务：


- 开始事务（）
- 命令入队（）
- 执行事务（）


```bash
#######################################################

#   multi   开始事务

#   exec    执行事务
127.0.0.1:6379> MULTI
OK
127.0.0.1:6379> set k1 v1
QUEUED
127.0.0.1:6379> set k2 v2
QUEUED
127.0.0.1:6379> get k2
QUEUED
127.0.0.1:6379> set k3 v3
QUEUED
127.0.0.1:6379> EXEC
1) OK
2) OK
3) "v2"
4) OK
#######################################################

#   discard 放弃事务（相当于回滚）
127.0.0.1:6379> MULTI
OK
127.0.0.1:6379> set k4 v4
QUEUED
127.0.0.1:6379> set k5 v5
QUEUED
127.0.0.1:6379> DISCARD
OK
127.0.0.1:6379> get k4
(nil)
```

### 编译型异常（代码有问题，命令有错），事务中的命令都不会执行


```bash
127.0.0.1:6379> MULTI
OK
127.0.0.1:6379> set k1 v1
QUEUED
127.0.0.1:6379> set k2 v2
QUEUED
127.0.0.1:6379> set k3 v3
QUEUED
127.0.0.1:6379> GETSET k4   #   错误命令
(error) ERR wrong number of arguments for 'getset' command
127.0.0.1:6379> set k4 v4
QUEUED
127.0.0.1:6379> set k5 v5
QUEUED
127.0.0.1:6379> EXEC    #   执行事务报错
(error) EXECABORT Transaction discarded because of previous errors.
127.0.0.1:6379> get k5  #   所有命令都不会执行
(nil)
```

### 运行时异常，如果队列中存在语法性（语法没有问题），那么执行命令的时候其他命令是可以正常执行的，错误命令抛出异常


```bash
127.0.0.1:6379> set k1 v1
OK
127.0.0.1:6379> MULTI
OK
127.0.0.1:6379> INCR k1 #   会执行报错
QUEUED
127.0.0.1:6379> set k2 v2
QUEUED
127.0.0.1:6379> set k3 v3
QUEUED
127.0.0.1:6379> get k3
QUEUED
127.0.0.1:6379> EXEC
1) (error) ERR value is not an integer or out of range  # 虽然第一条命令报错了，但其他还是正常执行了
2) OK
3) OK
4) "v3"
```

## Redis锁


### 悲观锁


很悲观，认为什么时候都会出现问题，无论做什么都会加锁


### 乐观锁


很乐观，认为什么时候都不会出现问题，所以不会上锁，更新的时候去判断一下，在此期间是否有人修改过值


主要通过获取version


更新的时候比较第一次获取的version


正常执行成功


```bash
127.0.0.1:6379> set money 100
OK
127.0.0.1:6379> set out 0
OK
127.0.0.1:6379> watch money # 监视money对象
OK
127.0.0.1:6379> MULTI   # 事务开始，事务执行期间数据没有发生变化，事务正常执行
OK
127.0.0.1:6379> DECR money
QUEUED
127.0.0.1:6379> INCR out
QUEUED
127.0.0.1:6379> EXEC
1) (integer) 99
2) (integer) 1
```

测试多线程修改值，使用watch可以当做redis的乐观锁操作


```bash
127.0.0.1:6379> watch money #监视money
OK
127.0.0.1:6379> MULTI
OK
127.0.0.1:6379> DECRBY money 20
QUEUED
127.0.0.1:6379> INCRBY out 20
QUEUED
127.0.0.1:6379> EXEC
(nil)
```

执行前另一个事务修改值


```bash
127.0.0.1:6379> INCRBY money 300
(integer) 399
```

## redis.conf详解


启动的时候就通过配置文件来启动


### 单位


![redis单位](https://xyf1111.github.io/images/redis-conf1.png)
*redis单位*

配置文件，unit单位，对大小写不敏感


### 包含


![redis包含](https://xyf1111.github.io/images/redis-conf2.png)
*redis包含*

导入文件


### 网络


```bash
bind 127.0.0.1  #   绑定的ip
protected-mode yes  #   保护模式是否开启
port 6379   #   端口号
```

### 通用GENERAL


```bash
daemonize yes   #   以守护进程的方式运行，默认是no
pidfile /var/run/redis_6379.pid   #   如果以后台的方式运行，我们就需要指定一个pid文件
```

### 日志


![redis日志](https://xyf1111.github.io/images/redis-conf3.png)
*redis日志*


```bash
logfile ""  #   日志的文件位置名
databases 16    #   数据库数量，默认是16个数据库
always-show-logo yes    #   是否总是显示logo
```

### 快照


持久化，在规定的时间执行了多少次操作，则会持久化到文件.rdb或.aof中


redis是内存数据库，如果没有持久化，数据库断点即失


```bash

# 如果900内至少有1个key进行修改，就会进行持久化操作
save 900 1

# 如果300内有10个key进行修改，就会进行持久化操作
save 300 10

# 如果60内有10000个key进行修改，就会进行持久化操作
save 60 10000
stop-writes-on-bgsave-error yes #   持久化如果出错是否还需要继续运行
rdbcompression yes  #   是否压缩rdb文件，需要消耗一些cpu资源
rdbchecksum yes #   保存rdb文件的时候，进行错误的检查校验
dir ./  #   rdb文件的保存路径
```

### REPLICATION 复制


### SECURITY 安全


### 限制CLIENTS


```bash
maxclients 10000    #   设置能连接上redis的最多客户端数量

maxmemory <bytes>   #   redis配置的最大内存容量

maxmemory-policy noeviction #   内存达到上限的处理策略
    1. volatile-lru：只对设置了过期时间的key进行LRU（默认值）
    2. allkeys-lru：删除LRU算法的key
    3. volatile-lfu：只对设置了过期时间的key进行LFU
    4. allkeys-lfu：删除LFU算法的key
    5. volatile-random：随机删除即将过期的key
    6. allkeys-random：随机删除
    7. volatile-ttl：删除即将过期的
    8. noeviction：永不过期，返回错误
```

### APPEND ONLY模式 aof持久化


```bash
appendonly no   #   默认是不开启aof模式
appendfilename "appendonly.aof" #   持久化文件的名字

# appendfsync always    #   每次修改都会sync。消耗性能
appendfsync everysec    #   每秒执行一次sync。可能会丢失这1s的数据

# appendfsync no        #   不执行sync，这个时候操作系统自己同步数据，速度最快
```

## Redis持久化


Redis是内存数据库，如果不将内存中的数据库状态保存到磁盘，那么一旦服务器进程退出，服务器中的数据库状态也会消失。所以redis提供了持久化功能


### RDB


什么是RDB


在指定的时间间隔内将内存中的数据集体快照写入磁盘中，也就是快照，恢复时是将快照文件直接读到内存中。


Redis会单独创建一个（fork）一个子进程进行持久化，会将数据写入到一个临时的文件中，待持久化过程都结束了，再用这个临时文件替换掉上次持久化好的文件。整个过程中，主进程不会进行任何IO操作。这就确保了极高的性能。如果需要大规模数据的恢复，且对数据恢复的完整性不是很敏感，RDB要比AOF高效。RDB缺点是最后一次持久化的数据可能丢失。


RDB保存的dump.rdb文件，在conf文件中进行配置


```bash
dbfilename dump.rdb
```

触发机制


1. save规则满足的情况下，会自动触发rdb规则
2. 执行flushall命令也会触发rdb规则
3. 退出redis，也会产生rdb文件
备份就会生成dump.rdb


如何恢复rdb文件


1. 只需要将rdb文件放在启动目录下即可，redis启动的时候回自动检查dump.rdb恢复其中的数据。
2. 查看需要存在的位置


```bash
127.0.0.1:6379> clear
127.0.0.1:6379> config get dir
1) "dir"
2) "/root"  #   如果目录下存在dump.rdb文件，启动的时候就会自动恢复其中的数据
```

几乎默认的配置就够用了


优点：


- 适合大规模的数据恢复！
- 如果对数据的完整性要求不高
缺点：
- 需要一定的时间间隔进行操作，如果redis意外宕机了，这个最后一次修改数据就没了
- fork进程的时候会占用一定的内容空间


### AOF（Append Only File）


什么是AOF：


将执行过的所有命令记录下来


以日志的形式来记录每个写操作，将Redis执行过程中的所有指令记录下来（读操作不记录），只许追加文件，但不可以改写文件，Redis启动之初会读取该文件重新构造数据。换言之，Redis重启的话就是根据日志文件的内容将写指令从前到后执行一次以完成数据的恢复工作。


AOF 保存的是appendonly.aof文件


默认是不开启的，需要手动进行配置，只许将appendonly改为yes就开启的AOF


重启，Redis就生效了


如果appendonly.aof文件有错，redis是启动不了的，需要修复aof文件。redis提供了一个工具redis-check-aof –fix


如果文件正常，重启就可以直接恢复了


优点：


- 每一次修改都同步，文件完整会更好
- 每秒同步一次，可能会丢失一秒的数据
- 从不同步，效率最高
缺点：
- 相对于数据文件来说，aof远大于rdb，修复速度也比rdb慢
- aof运行效率比rdb慢，所以默认的是rdb持久化


## Redis订阅发布


订阅端


```bash
127.0.0.1:6379> SUBSCRIBE cc    #   订阅一个频道
Reading messages... (press Ctrl-C to quit)
1) "subscribe"
2) "cc"
3) (integer) 1

#   等待读取推送的信息
1) "message"        #消息
2) "cc"             #频道
3) "hello,world"    #具体内容
```

发送端


```bash
127.0.0.1:6379> PUBLISH cc hello,world  #   发布者发布消息到频道
(integer) 1
```