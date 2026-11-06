---
title: "Java 26 - Quartz 定时任务"
date: 2026-07-24
tags:
  - java
  - spring
  - quartz
  - 定时任务
source: "鱼皮·编程导航 / codefather"
---

# Java 26 — Quartz 定时任务

> Quartz 是功能强大的 Java 调度框架，比 `@Scheduled` 注解更灵活，支持动态增删改查任务。

## 核心概念

| 组件 | 职责 |
|------|------|
| **Job** | 执行实际任务的对象，需实现 `execute()` 方法 |
| **Trigger** | 规定任务执行时间、频率的对象（如 Cron 表达式） |
| **Scheduler** | 管理调度 Job 和 Trigger，负责绑定与执行 |

## Maven 依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-quartz</artifactId>
    <version>2.2.3</version>
</dependency>
```

## 实现步骤

### 1. 创建 Job

```java
@Slf4j
public class InsertJob implements Job {
    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {
        System.out.println(new Date());
        System.out.println("执行定时任务");
        // 通过 SpringContextHolder 获取 Spring Bean
        MeterReadingMonthMapper mapper = SpringContextHolder.getBean(MeterReadingMonthMapper.class);
        try {
            mapper.insertLastMonthlyWaterConsumption();
            System.out.println("定时任务执行成功！");
        } catch (Exception e) {
            throw new JobExecutionException("定时任务执行失败！");
        }
    }
}
```

> **注意**: Quartz 的 Job 由 Quartz 内部实例化，无法使用 `@Autowired` 注入 Spring Bean。需要通过 `SpringContextHolder` 工具类手动获取。

### 2. 创建 SpringContextHolder 工具类

```java
@Component
public class SpringContextHolder implements ApplicationContextAware {

    private static ApplicationContext applicationContext;

    public void setApplicationContext(ApplicationContext ctx) {
        applicationContext = ctx;
    }

    public static <T> T getBean(Class<T> clazz) {
        Map beanMaps = applicationContext.getBeansOfType(clazz);
        if (beanMaps != null && !beanMaps.isEmpty()) {
            return (T) beanMaps.values().iterator().next();
        }
        return null;
    }

    public static boolean containsBean(String name) {
        return applicationContext.containsBean(name);
    }
}
```

### 3. 创建 Scheduler 与 Trigger

```java
public class InsertRunner extends Thread {
    @Override
    public void run() {
        try {
            SchedulerFactory factory = new StdSchedulerFactory();
            Scheduler scheduler = factory.getScheduler();

            Trigger trigger = TriggerBuilder.newTrigger()
                    .withIdentity("everymonth", "myInsert")
                    .withSchedule(CronScheduleBuilder.cronSchedule("0/5 * * * * ?"))
                    .build();

            JobDetail job = JobBuilder.newJob(InsertJob.class)
                    .withIdentity(trigger.getKey().getName(), trigger.getKey().getGroup())
                    .build();

            scheduler.scheduleJob(job, trigger);
            scheduler.start();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
```

### 4. 启动时启用

通过配置项控制是否开启定时任务：

```yaml
# application.yml
task:
  insertTask:
    insertMonth: 1   # 1=开启定时任务
```

```java
@Value("${task.insertTask.insertMonth}")
private String insertMonth;

@PostConstruct
public void init() throws Exception {
    if ("1".equals(insertMonth)) {
        new Thread(new InsertRunner()).start();
    }
}
```

## 工具

- [Cron 在线表达式生成器](http://cron.ciding.cc/)

> 来源：鱼皮·编程导航 / codefather
