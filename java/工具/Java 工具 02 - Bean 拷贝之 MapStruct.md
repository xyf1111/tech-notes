---
title: "Java 工具 - Bean 拷贝之 MapStruct"
date: 2026-07-20
tags: [Java, 工具, MapStruct, Bean映射]
source: "鱼皮·编程导航 / codefather"
---

# Java 工具 - Bean 拷贝之 MapStruct

> MapStruct 是一款编译时 Java Bean 映射器，通过注解在编译期生成映射代码，避免手写繁琐的 getter/setter 模板代码。

## 传统写法的问题

```java
// 手写转换 - 繁琐且容易出错
public static ArticleDTO toDto(ArticleDO articleDO) {
    if (articleDO == null) return null;
    ArticleDTO articleDTO = new ArticleDTO();
    articleDTO.setAuthor(articleDO.getUserId());
    articleDTO.setArticleId(articleDO.getId());
    articleDTO.setArticleType(articleDO.getArticleType());
    articleDTO.setTitle(articleDO.getTitle());
    // ... 大量 setter 代码
    return articleDTO;
}
```

批量转换还需要遍历：
```java
public static List<ArticleDTO> toArticleDtoList(List<ArticleDO> articleDOS) {
    return articleDOS.stream().map(ArticleConverter::toDto).collect(Collectors.toList());
}
```

**BeanUtils 的问题**：存在反射性能开销、类型转换隐患、复杂映射难以处理等缺陷。

## MapStruct 核心用法

### 1. 引入依赖

```xml
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct</artifactId>
    <version>1.5.5.Final</version>
</dependency>
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct-processor</artifactId>
    <version>1.5.5.Final</version>
</dependency>
```

| 依赖 | 作用 |
|------|------|
| `mapstruct` | 核心库，提供 `@Mapper`、`@Mapping` 等注解 |
| `mapstruct-processor` | 注解处理器（compile 作用域），编译时生成实现代码 |

> 注意 guava 版本冲突，建议使用 19.0+。

### 2. 定义映射器接口

```java
@Mapper
public interface ColumnStructMapper {
    ColumnStructMapper INSTANCE = Mappers.getMapper(ColumnStructMapper.class);

    // 基本映射：source → target
    @Mapping(source = "id", target = "columnId")
    @Mapping(source = "columnName", target = "column")
    @Mapping(source = "userId", target = "author")
    // Date → Long（表达式转换）
    @Mapping(target = "publishTime", expression = "java(columnInfoDO.getPublishTime().getTime())")
    @Mapping(target = "freeStartTime", expression = "java(columnInfoDO.getFreeStartTime().getTime())")
    @Mapping(target = "freeEndTime", expression = "java(columnInfoDO.getFreeEndTime().getTime())")
    ColumnDTO infotoDto(ColumnInfoDO columnInfoDO);

    // 列表转换（自动复用单对象映射规则）
    List<ColumnDTO> infoToDtos(List<ColumnInfoDO> columnInfoDOs);

    // 反向映射
    @Mapping(source = "column", target = "columnName")
    @Mapping(source = "author", target = "userId")
    @Mapping(target = "freeStartTime", expression = "java(new java.util.Date(req.getFreeStartTime()))")
    @Mapping(target = "freeEndTime", expression = "java(new java.util.Date(req.getFreeEndTime()))")
    ColumnInfoDO toDo(ColumnReq req);
}
```

### 3. @Mapping 注解详解

| 用法 | 示例 | 说明 |
|------|------|------|
| **基本映射** | `@Mapping(source = "name", target = "fullName")` | 源属性 → 目标属性 |
| **常量映射** | `@Mapping(target = "status", constant = "ACTIVE")` | 固定值设置 |
| **默认值** | `@Mapping(source = "count", target = "total", defaultValue = "0")` | 源为 null 时使用默认值 |
| **表达式** | `@Mapping(target = "ts", expression = "java(src.getDate().getTime())")` | 复杂 Java 表达式 |
| **日期格式** | `@Mapping(source = "date", target = "formattedDate", dateFormat = "yyyy-MM-dd")` | 日期↔字符串 |
| **条件映射** | `@Mapping(target = "data", qualifiedByName = "specialConverter")` | 指定转换方法 |
| **嵌套映射** | `@Mapping(source = "address.street", target = "streetName")` | 点号访问嵌套属性 |
| **忽略字段** | `@Mapping(target = "internalId", ignore = true)` | 跳过特定字段 |
| **自定义方法** | `@Mapping(target = "data", source = "value", qualifiedByName = "customMethod")` | 调用自定义转换 |

### 4. 同名映射（无注解）

当源对象和目标对象的字段名和类型完全一致时，无需任何注解：

```java
@Mapper
public interface SimpleSourceDestinationMapper {
    SimpleSourceDestinationMapper INSTANCE = Mappers.getMapper(SimpleSourceDestinationMapper.class);
    SimpleDestination sourceToDestination(SimpleSource source);
    SimpleSource destinationToSource(SimpleDestination destination);
}
```

```java
// 使用
SimpleDestination dest = SimpleSourceDestinationMapper.INSTANCE.sourceToDestination(source);
```

### 5. Spring 依赖注入

在 `@Mapper` 中添加 `componentModel = "spring"` 参数：

```java
@Mapper(componentModel = "spring")
public interface ColumnStructMapper {}
```

使用方：

```java
@Autowired
private ColumnStructMapper columnStructMapper;

public void test() {
    ColumnInfoDO result = columnStructMapper.toDo(req);
}
```

## 替代方案：BaseData 反射工具类

当无法安装 MapStruct 插件（如云桌面受限环境）时，可使用基于反射的 `BaseData` 接口方案，通过 `BeanUtils.copyProperties` + 自定义接口实现对象转换。

### 问题场景

Spring 的 `BeanUtils.copyProperties()` 有两个缺点：
1. 目标对象需要手动 `new` 实例
2. 字段需要手动 `set` 时会导致代码冗长
3. 集合转换时 Sonar 会报「不能在循环中创建对象」

### BaseData 接口实现

```java
public interface BaseData {

    /** 将当前对象转换为目标对象，并执行额外操作 */
    default <V> V asTargetObject(Class<V> clazz, Consumer<V> consumer) {
        V v = this.asTargetObject(clazz);
        consumer.accept(v);
        return v;
    }

    /** 将当前对象转换为目标对象 */
    default <V> V asTargetObject(Class<V> clazz) {
        try {
            Field[] declaredFields = clazz.getDeclaredFields();
            Constructor<V> constructor = clazz.getConstructor();
            V v = constructor.newInstance();
            Arrays.stream(declaredFields).forEach(declaredField -> convert(declaredField, v));
            return v;
        } catch (ReflectiveOperationException e) {
            throw new BusinessException(ErrorCode.CAST_OBJECT_ERROR);
        }
    }

    /** 字段转换并赋值 */
    default void convert(Field field, Object vo) {
        try {
            Field source = this.getClass().getDeclaredField(field.getName());
            ReflectionUtils.makeAccessible(field);
            ReflectionUtils.makeAccessible(source);
            Method sourceGetter = this.getClass().getMethod("get" + capitalize(field.getName()));
            Method targetSetter = vo.getClass().getMethod("set" + capitalize(field.getName()), field.getType());
            Object value = sourceGetter.invoke(this);
            targetSetter.invoke(vo, value);
        } catch (NoSuchFieldException | InvocationTargetException | IllegalAccessException |
                 NoSuchMethodException ignored) {
            // 忽略字段数不一致的异常，额外字段可在 consumer 中处理
        }
    }

    default String capitalize(String str) {
        if (str == null || str.isEmpty()) return str;
        return Character.toUpperCase(str.charAt(0)) + str.substring(1);
    }
}
```

### 使用方式

**1. DTO 实现 BaseData 接口：**

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class AccountDTO implements BaseData {
    private Long id;
    private String username;
    private String gender;
    // ...
}
```

**2. 单个对象转换：**

```java
AccountDTO accountDTO = new AccountDTO(1L, "test", "男", ...);
AccountVO accountVO = accountDTO.asTargetObject(AccountVO.class, v -> {
    v.setGenderNum(Objects.equals(accountDTO.getGender(), "男") ? "1" : "0");
});
```

**3. 集合转换：**

```java
List<AccountVO> list = accountDTOList.stream()
    .map(source -> source.asTargetObject(AccountVO.class, v -> {
        v.setGenderNum(Objects.equals(source.getGender(), "男") ? "1" : "0");
    }))
    .collect(Collectors.toList());
```

### 注意事项

- 两个类中**相同字段名的字段类型必须完全一致**
- Lombok 版本建议 1.18.28+，`isDelete` 等 `is` 开头字段自动支持
- 未使用 Lombok 时需手动添加 `getIsDelete()` 等方法
- 反射方案有少量运行时开销，适合数据量较小的场景；高性能场景仍推荐 MapStruct

## 工作原理

MapStruct 在 **编译时** 生成映射器实现类（而非运行时反射），生成的是普通的 Java setter 代码，无反射开销。

```java
// 自动生成的实现类
public class SimpleSourceDestinationMapperImpl implements SimpleSourceDestinationMapper {
    public SimpleDestination sourceToDestination(SimpleSource source) {
        if (source == null) return null;
        SimpleDestination dest = new SimpleDestination();
        dest.setName(source.getName());
        dest.setDescription(source.getDescription());
        return dest;
    }
}
```

## IDEA 插件

安装 MapStruct 插件后，可在 `@Mapper` 接口和其实现类之间快速导航。

> 来源：鱼皮·编程导航 / codefather
