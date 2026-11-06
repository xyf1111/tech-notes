---
title: "Java 工具 - EasyExcel 导入导出"
date: 2026-07-21
tags: [Java, 工具, EasyExcel, Excel处理]
source: "鱼皮·编程导航 / codefather"
---

# Java 工具 - EasyExcel 导入导出

> EasyExcel 是阿里巴巴开源的 Excel 处理库，相比 Apache POI 内存占用更低、API 更简洁，适用于服务端大数据量导出。

## 引入依赖

```xml
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>easyexcel</artifactId>
    <version>3.2.1</version>
</dependency>
```

## 定义导出对象

使用注解配置列宽、格式、列名和顺序：

```java
@Data
public class IndentExcelVO {

    @ColumnWidth(20)
    @NumberFormat("#")
    @ExcelProperty(value = "订单编号", index = 0)
    private String id;

    @ExcelProperty(value = "用户姓名", index = 1)
    private String realName;

    @ColumnWidth(15)
    @ExcelProperty(value = "手机号", index = 2)
    private String information;

    @ColumnWidth(15)
    @ExcelProperty(value = "接亲日期", index = 3)
    private String date_time;

    @ColumnWidth(15)
    @ExcelProperty(value = "开始时间", index = 4)
    private String start_time;

    @ColumnWidth(15)
    @ExcelProperty(value = "结束时间", index = 5)
    private String end_time;

    @ColumnWidth(20)
    @ExcelProperty(value = "接亲地址", index = 6)
    private String address;

    @NumberFormat("#")
    @ExcelProperty(value = "订单总金额", index = 7)
    private Double amount;

    @ExcelProperty(value = "订单状态", index = 8)
    private String indent_state;

    @ExcelProperty(value = "支付状态", index = 9)
    private String payment_state;

    @ColumnWidth(15)
    @ExcelProperty(value = "订单创建时间", index = 10)
    private String createTime;
}
```

## 编写导出接口

### 工具类

```java
public class ExcelUtils {

    public static String getPath() {
        return ExcelUtils.class.getResource("/").getPath();
    }

    public static File createNewFile(String pathName) {
        File file = new File(getPath() + pathName);
        if (file.exists()) {
            file.delete();
        } else {
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
        }
        return file;
    }

    public static void setExcelResponseProp(HttpServletResponse response, String rawFileName) throws IOException {
        response.setContentType("application/vnd.vnd.ms-excel");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode(rawFileName.concat(".xlsx"), "UTF-8");
        response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName);
    }

    public static String dateToString(Date date) {
        if (date == null) throw new BusinessException(ErrorCode.NOT_FOUND_ERROR);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(date);
    }
}
```

### Controller

```java
@GetMapping("/download")
@AuthCheck(mustRole = ADMIN_ROLE)
public void download(HttpServletResponse response) throws IOException {
    List<Indent> data = indentService.list();
    List<IndentExcelVO> indentList = data.stream().map(item -> {
        IndentExcelVO vo = new IndentExcelVO();
        BeanUtils.copyProperties(item, vo);
        vo.setDate_time(ExcelUtils.dateToString(item.getDate_time()));
        vo.setCreateTime(ExcelUtils.dateToString(item.getCreateTime()));
        return vo;
    }).collect(Collectors.toList());

    ExcelUtils.setExcelResponseProp(response, "订单信息");
    OutputStream outputStream = response.getOutputStream();
    EasyExcel.write(outputStream, IndentExcelVO.class)
        .sheet("订单数据")
        .doWrite(indentList);
}
```

## 常见问题：Date 字段导出

**问题：** 导出 Excel 文件无数据，报错 `Can not find 'Converter' support class Date.`

**原因：** EasyExcel 默认不支持 `DateTime` 日期格式，需要指定日期格式。

**解决方式 1：将 Date 转为 String**

在导出前将 Date 字段转换为字符串：

```java
List<IndentExcelVO> indentList = data.stream().map(item -> {
    IndentExcelVO vo = new IndentExcelVO();
    BeanUtils.copyProperties(item, vo);
    vo.setDate_time(ExcelUtils.dateToString(item.getDate_time()));
    vo.setCreateTime(ExcelUtils.dateToString(item.getCreateTime()));
    return vo;
}).collect(Collectors.toList());
```

**解决方式 2：自定义转换器**

定义 `Converter` 实现类，在 `@ExcelProperty` 注解中指定 `converter` 属性。

## 读取表格

EasyExcel 读取表格有两种方式：**创建对象的读** 和 **不创建对象的读**。

### 创建对象的读

已知表头列名和列类型时，创建对应类来表示表格元信息。默认按属性声明顺序关联列，也可用注解指定下标或列名：

```java
@Data
public class YupiData {
    // 强制读取下标为 2 的列（第三列），并指定日期格式
    @ExcelProperty(index = 2)
    @DateTimeFormat("yyyy/MM/dd")
    private Date bornDate;

    // 按列名匹配，不能与其他列重名
    @ExcelProperty("年龄")
    private Integer age;

    @ExcelProperty("姓名")
    private String name;
}
```

**同步读取**：一次性加载所有行到内存，适合表格行数少的场景：

```java
List<YupiData> list = EasyExcel.read(fileName)
        .head(YupiData.class)
        .sheet()
        .doReadSync();
```

**异步读取**：定义 `ReadListener` 监听器，每读一行立即处理一行，无需全部加载进内存：

```java
public class YupiDataListener implements ReadListener<YupiData> {
    // 每读一行数据调用一次
    @Override
    public void invoke(YupiData data, AnalysisContext context) {
        System.out.println(data.getName());
    }
}

EasyExcel.read(fileName, YupiData.class, new YupiDataListener())
        .sheet()
        .doRead();
```

## 不创建对象的读

事先不清楚表格有哪些列、类型如何（如用户自主上传的表格），直接用 `Map<Integer, String>` 接收，key 为列下标：

```java
List<Map<Integer, String>> list = EasyExcel.read(fileName)
        .sheet()
        .doReadSync();
// Map 的 key 为列下标，value 为单元格的值
for (Map<Integer, String> data : list) {
    // 处理每一行
}
```

该方式同样支持同步和异步读取。

## 写入表格：调换列顺序

写入同样先定义类表示表格元信息；要调换列顺序，只需调换类属性的声明顺序：

```java
@Data
public class YupiWriteData {
    private Integer age;   // 年龄（第 0 列）
    private String name;   // 姓名（第 1 列）
    private Date bornDate; // 出生日期
}
```

然后执行 write 方法：

```java
List<YupiWriteData> dataList = xxx;  // 已处理好的数据
EasyExcel.write(fileName, YupiWriteData.class)
        .sheet("工作表1")
        .doWrite(dataList);
```

> 来源：鱼皮·编程导航 / codefather
