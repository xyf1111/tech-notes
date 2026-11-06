---
title: "Java 工具 11 - Spring JDBC 操作数据库"
date: 2026-08-06
tags: [java, springboot, jdbc, jdbctemplate, 多数据源]
source: "鱼皮·编程导航 / codefather"
---

# Java 工具 11 - Spring JDBC 操作数据库

> 使用 Spring Boot 官方 `spring-boot-starter-jdbc`（JdbcTemplate）操作数据库，并实现多数据源配置，为分库分表打基础。

## JDBC 概念

JDBC（Java DataBase Connectivity）是一种用于**执行 SQL 语句的 Java API**，为多种关系数据库提供统一访问，由一组 Java 类和接口组成，是构建更高级工具和接口的基准。

> 持久层：对数据进行持久化操作的代码（保存到数据库、文件、磁盘等）。Web 应用最常用的持久层框架是 JDBC、MyBatis、JPA。

现在开发普遍使用 ORM 持久化框架，但其底层仍是 JDBC 技术，了解 JDBC 能扩展技术面，更灵活地操作数据库。

### 直接使用 JDBC 操作数据库的 7 步流程

1. 加载数据库驱动
2. 建立数据库连接
3. 创建数据库操作对象
4. 定义操作 SQL 语句
5. 执行数据库操作
6. 获取并操作结果集
7. 关闭对象，回收资源

```java
try {
    // 1、加载数据库驱动
    Class.forName(driver);
    // 2、获取数据库连接
    conn = DriverManager.getConnection(url, username, password);
    // 3、获取数据库操作对象
    stmt = conn.createStatement();
    // 4、定义操作的 SQL 语句
    String sql = "select * from user where id = 6";
    // 5、执行数据库操作
    rs = stmt.executeQuery(sql);
    // 6、获取并操作结果集
    while (rs.next()) {
        // 解析结果集
    }
} catch (Exception e) {
    // 日志信息
} finally {
    // 7、关闭资源
}
```

直接使用 JDBC 操作数据库比较复杂，Spring Boot 提供了 `spring-boot-starter-jdbc`（在 Spring JDBC 基础上进一步封装），方便在 Spring Boot 生态中使用。若企业已有成熟的 ORM 积累且无特殊需求，不建议直接使用 JDBC。

## 集成 Spring JDBC 到 Spring Boot

### 引入依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-jdbc</artifactId>
</dependency>
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
</dependency>
```

### yml 配置数据源

```yaml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/test_db?useSSL=false&useUnicode=true&characterEncoding=UTF-8&serverTimezone=GMT%2B8
    username: root
    password: 123456
```

### 建表与实体类

新建测试表 article，并定义对应实体类：

```sql
CREATE TABLE `article` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `author` VARCHAR(32) NOT NULL,
  `title` VARCHAR(32) NOT NULL,
  `content` VARCHAR(512) NOT NULL,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) COMMENT='文章' ENGINE=InnoDB;
```

### DAO 层：JdbcTemplate CRUD

`@Repository` 标识持久层组件，注入 JdbcTemplate。方法选用原则：

- `jdbcTemplate.update()` 适合 insert / update / delete 操作
- `jdbcTemplate.queryForObject()` 查询单条记录
- `jdbcTemplate.query()` 查询结果列表
- `BeanPropertyRowMapper` 将数据库字段映射到实体类，支持驼峰自动映射（如 `create_time` → `createTime`）

```java
@Repository  // 持久层依赖注入注解
public class ArticleJDBCDAO {

    @Resource
    private JdbcTemplate jdbcTemplate;

    // 保存文章
    public void save(Article article) {
        jdbcTemplate.update("INSERT INTO article(author, title, content, create_time) values(?, ?, ?, ?)",
                article.getAuthor(), article.getTitle(), article.getContent(), article.getCreateTime());
    }
    // 删除文章
    public void deleteById(Long id) {
        jdbcTemplate.update("DELETE FROM article WHERE id = ?", id);
    }
    // 更新文章
    public void updateById(Article article) {
        jdbcTemplate.update("UPDATE article SET author = ?, title = ?, content = ?, create_time = ? WHERE id = ?",
                article.getAuthor(), article.getTitle(), article.getContent(), article.getCreateTime(), article.getId());
    }
    // 根据 id 查找文章（单条）
    public Article findById(Long id) {
        return jdbcTemplate.queryForObject("SELECT * FROM article WHERE id = ?",
                new Object[]{id}, new BeanPropertyRowMapper<>(Article.class));
    }
    // 查询所有（列表）
    public List<Article> findAll() {
        return jdbcTemplate.query("SELECT * FROM article", new BeanPropertyRowMapper<>(Article.class));
    }
}
```

### Service 层

```java
@Slf4j
@Service  // 服务层依赖注入注解
public class ArticleJDBCService implements ArticleService {

    @Resource
    private ArticleJDBCDAO articleJDBCDAO;

    @Transactional
    public void saveArticle(Article article) {
        articleJDBCDAO.save(article);
        // int a = 2 / 0;  // 人为制造异常，用于测试事务
    }
    public void deleteArticle(Long id) {
        articleJDBCDAO.deleteById(id);
    }
    public void updateArticle(Article article) {
        articleJDBCDAO.updateById(article);
    }
    public Article getArticle(Long id) {
        return articleJDBCDAO.findById(id);
    }
    public List<Article> getAll() {
        return articleJDBCDAO.findAll();
    }
}
```

在 Controller 层调用 Service 接口即可。注意：Spring JDBC 会自动把数据库下划线命名转换成实体类的驼峰命名，SQL 语句里的字段名必须是数据库字段名。

测试数据示例：

```json
{"author": "xhl", "title": "Sample Article", "content": "This is the content of the article.", "createTime": "2023-11-05 15:30:00"}
```

## 事务测试

- 在 `saveArticle` 方法上使用 `@Transactional` 注解，基本功能为事务管理：保证方法一旦有异常，所有数据库操作全部回滚。
- 人为制造"被除数为 0"的异常（`int a = 2 / 0;`）验证回滚，测试成功。

## Spring JDBC 多数据源

随着应用的数据量增多，很可能采用**数据分库存储**方案，持久层代码可能面临在一个服务函数中操作多个数据库的场景。

### 一、yml 配置多个数据源

配置两个数据源 primary 和 secondary，注意两个数据源连接的是不同的库：

```yaml
spring:
  datasource:
    primary:
      driver-class-name: com.mysql.cj.jdbc.Driver
      jdbc-url: jdbc:mysql://localhost:3306/test_db?useSSL=false&useUnicode=true&characterEncoding=UTF-8&serverTimezone=GMT%2B8
      username: root
      password: 123456
    secondary:
      driver-class-name: com.mysql.cj.jdbc.Driver
      jdbc-url: jdbc:mysql://localhost:3306/xuexi?useSSL=false&useUnicode=true&characterEncoding=UTF-8&serverTimezone=GMT%2B8
      username: root
      password: 123456
```

> 注意：多数据源配置用的是 `jdbc-url` 而不是 `url`（详见常见 Bug）。

### 二、Java Config 配置类

`@Configuration` 将类标记为配置类；`@Bean` 把返回对象注册为 Bean；`@ConfigurationProperties(prefix=...)` 按配置前缀自动装配；`@Qualifier` 指定用哪个数据源 Bean 创建 JdbcTemplate。

```java
@Configuration
public class DataSourceConfig {

    @Primary
    @Bean(name = "primaryDataSource")
    @ConfigurationProperties(prefix = "spring.datasource.primary")   // test_db
    public DataSource primaryDataSource() {
        return DataSourceBuilder.create().build();
    }
    @Bean(name = "secondaryDataSource")
    @ConfigurationProperties(prefix = "spring.datasource.secondary") // xuexi
    public DataSource secondaryDataSource() {
        return DataSourceBuilder.create().build();
    }
    @Bean(name = "primaryJdbcTemplate")
    public JdbcTemplate primaryJdbcTemplate(@Qualifier("primaryDataSource") DataSource dataSource) {
        return new JdbcTemplate(dataSource);
    }
    @Bean(name = "secondaryJdbcTemplate")
    public JdbcTemplate secondaryJdbcTemplate(@Qualifier("secondaryDataSource") DataSource dataSource) {
        return new JdbcTemplate(dataSource);
    }
}
```

### @Primary 与 @Qualifier 的作用

- **@Primary**：当一个接口有多个实现类（Bean）时，标注在主实现类上。Spring 只能选一个 Bean 进行依赖注入时，默认选择被 `@Primary` 标识的那个（若项目只使用一个数据源，就是 primaryDataSource）。
- **@Qualifier**：通过编码明确指定，当接口有多个实现 Bean 时到底使用哪一个（如用 `primaryDataSource` 创建 `primaryJdbcTemplate`）。

### 三、DAO 改造

1. 注入 primaryJdbcTemplate 作为默认的数据库操作对象。
2. 将 jdbcTemplate 作为参数传入 DAO 方法，**不同的 template 操作不同的库**。

```java
@Resource
private JdbcTemplate primaryJdbcTemplate;  // 默认数据库操作对象
// 保存文章：新增 jdbcTemplate 参数，其他方法照做
public void save(Article article, JdbcTemplate jdbcTemplate) {
    if (jdbcTemplate == null) {  // 参数为空时回退 primaryJdbcTemplate
        jdbcTemplate = primaryJdbcTemplate;
    }
    jdbcTemplate.update("insert into article(author, title, content, create_time) values(?,?,?,?)",
            article.getAuthor(), article.getTitle(), article.getContent(), article.getCreateTime());
}
```

### 四、单元测试：同时向两个数据库保存数据

注意注入 JdbcTemplate 时，名字要与配置类中定义的 Bean 名对应。测试成功后，test_db 和 xuexi 两个库的 article 表应各插入一条数据。

```java
@SpringBootTest
public class SpringJdbcTest {

    @Resource
    private ArticleJDBCDAO articleJDBCDAO;
    @Resource
    private JdbcTemplate primaryJdbcTemplate;
    @Resource
    private JdbcTemplate secondaryJdbcTemplate;
    @Test
    public void testJdbc() {
        articleJDBCDAO.save(Article.builder()
                .author("xhl").title("primaryJdbcTemplate").content("测试").createTime(new Date()).build(),
                primaryJdbcTemplate);
        articleJDBCDAO.save(Article.builder()
                .author("xhl").title("secondaryJdbcTemplate").content("测试").createTime(new Date()).build(),
                secondaryJdbcTemplate);
    }
}
```

### 常见 Bug：jdbcUrl is required with driverClassName

Spring Boot 2.0+ 配置多数据源时报 `jdbcUrl is required with driverClassName`，解决：把配置项 `url` 改成 `jdbc-url` 即可。

## 总结

JdbcTemplate 封装了 JDBC 的样板代码，配合 `@Transactional` 事务与多数据源配置，可在单个服务中灵活操作多个数据库，为后续分库分表打下基础。

> 来源：鱼皮·编程导航 / codefather
