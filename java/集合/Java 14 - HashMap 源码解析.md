---
title: "Java 14 - HashMap 源码解析"
date: 2026-08-19
tags: [java, 集合, HashMap, 源码]
source: "鱼皮·编程导航 / codefather"
---

# Java 14 - HashMap 源码解析

> 面试超高频考点的 HashMap 源码逐行解析：数据结构、扰动函数、put/get 流程、扩容与树化

## 总览（设计要点）

- HashMap 实现 Map 接口，**允许 null 键和 null 值**；与 Hashtable 大致相当，但**非同步**（线程不安全）。
- **不保证映射顺序**，且顺序不会随时间保持不变（resize 重哈希后元素位置会改变）。
- get/put 基本操作提供**常数时间**性能；迭代时间与"容量 + 大小"成正比，因此若迭代性能重要，初始容量不宜过高、负载因子不宜过低。
- 两个性能参数：**初始容量**（创建时的桶数量/数组大小）与**负载因子**（数组被填充的最大密度）。当键值对数量超过 `容量 × 负载因子` 时触发扩容，容量加倍，所有键值对重新哈希并迁移。
- 默认负载因子 **0.75**，在时间与空间成本间提供良好折衷。若 `初始容量 > 条目数 / 负载因子`，则永远不会扩容。
- 哈希冲突会降低性能；当键实现 `Comparable` 接口时，哈希相同的键可按大小顺序决定桶内存储位置，缓解冲突。

## 关键变量

| 变量 | 含义 |
|---|---|
| `table` | 存储键值对的 Node 数组，HashMap 的核心数据结构 |
| `size` | 当前存储的键值对数量 |
| `threshold` | 扩容阈值，等于 `table.length * loadFactor` |
| `loadFactor` | 负载因子，默认 0.75 |

### 阈值常量表

| 常量 | 值 | 含义 |
|---|---|---|
| `DEFAULT_INITIAL_CAPACITY` | 16 | 默认初始容量 |
| `MAXIMUM_CAPACITY` | `1 << 30` | 容量上限 |
| `TREEIFY_THRESHOLD` | 8 | 链表长度 ≥ 8 时树化为红黑树 |
| `UNTREEIFY_THRESHOLD` | 6 | 红黑树节点数 ≤ 6 时退化为链表 |
| `MIN_TREEIFY_CAPACITY` | 64 | 数组容量 ≥ 64 才允许树化（容量不足时先扩容） |

## 关键内部类

### Node

数组元素，实现 `Map.Entry<K,V>`，是数组中存储的对象：

```java
static class Node<K,V> implements Map.Entry<K,V> {
    final int hash;      // 存储键的哈希值
    final K key;         // 键
    V value;             // 值
    Node<K,V> next;      // 链表指针
}
```

### TreeNode

红黑树节点，链表过长树化后使用，提供 `putTreeVal`（树插入）、`getTreeNode`（树查找）、`split`（扩容拆分）等树操作。

## 构造方法

```java
public HashMap(int initialCapacity, float loadFactor) {
    // 检查参数合法性
    if (initialCapacity < 0)
        throw new IllegalArgumentException("Illegal initial capacity: " + initialCapacity);
    if (initialCapacity > MAXIMUM_CAPACITY)
        initialCapacity = MAXIMUM_CAPACITY;
    if (loadFactor <= 0 || Float.isNaN(loadFactor))
        throw new IllegalArgumentException("Illegal load factor: " + loadFactor);
    this.loadFactor = loadFactor;
    // 注意：此处 threshold 暂存的是"容量"（tableSizeFor 得到的 2 的幂），
    // 并非真正的扩容阈值；真正的数组在首次 put 时由 resize() 创建
    this.threshold = tableSizeFor(initialCapacity);
}
```

设计要点：
- 构造方法**只做参数校验与暂存容量，不实例化数组**（懒加载，首次 put 时才建数组）。
- `tableSizeFor` 把传入容量向上取整为 **2 的幂**，这是 `(n - 1) & hash` 位运算定位下标的前提。

## 扰动函数 hash()

```java
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```

- **为什么需要**：数组下标计算公式为 `i = (n - 1) & hash`（n 是 2 的幂时，位运算等价于取模且更快，且 `n - 1` 二进制位全为 1，保证结果小于 n）。但这样只用到 hash 的**低位**，若 hashCode 低位分布不佳，碰撞会很严重。
- **怎么做**（三步）：① `key.hashCode()` 得到哈希值赋给 h；② h 无符号右移 16 位；③ 与原来的 h 做异或。即**高 16 位与低 16 位混合**，让高位信息参与低位计算，加大低位的随机性，同时保留高位特征。
- **null 键**：hash 固定为 0，落在 0 号桶。

## put 流程

核心方法 `putVal(hash, key, value, onlyIfAbsent, evict)`：

```java
final V putVal(int hash, K key, V value, boolean onlyIfAbsent, boolean evict) {
    Node<K,V>[] tab; Node<K,V> p; int n, i;
    // 1. 数组为空则先 resize 初始化
    if ((tab = table) == null || (n = tab.length) == 0)
        n = (tab = resize()).length;
    // 2. 下标处为空，直接放新节点
    if ((p = tab[i = (n - 1) & hash]) == null)
        tab[i] = newNode(hash, key, value, null);
    else {
        Node<K,V> e; K k;
        // 3. 首节点键相同 -> 准备覆盖
        if (p.hash == hash &&
            ((k = p.key) == key || (key != null && key.equals(k))))
            e = p;
        // 4. 树节点 -> 走红黑树插入
        else if (p instanceof TreeNode)
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
        else {
            // 5. 遍历链表：尾部插入新节点
            for (int binCount = 0; ; ++binCount) {
                if ((e = p.next) == null) {
                    p.next = newNode(hash, key, value, null);
                    // 链表长度达到阈值 -> 树化
                    if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                        treeifyBin(tab, hash);
                    break;
                }
                // 找到相同键，跳出准备覆盖
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    break;
                p = e;
            }
        }
        // 6. 命中相同键：按 onlyIfAbsent 决定是否覆盖，返回旧值
        if (e != null) {
            V oldValue = e.value;
            if (!onlyIfAbsent || oldValue == null)
                e.value = value;
            afterNodeAccess(e); // 空回调，供 LinkedHashMap 扩展
            return oldValue;
        }
    }
    ++modCount;              // 结构性修改计数 +1
    if (++size > threshold)  // 7. 超过阈值 -> 扩容
        resize();
    afterNodeInsertion(evict); // 空回调
    return null;
}
```

流程小结：**计算下标 → 空桶直接插入 → 键相同覆盖 → 树节点走树插入 → 链表尾插（超 8 树化）→ 超过阈值扩容**。

扩展点：`afterNodeAccess` / `afterNodeInsertion` / `afterNodeRemoval` 在 HashMap 中均为空方法（包级 protected，注释说明专为 LinkedHashMap 设计），**LinkedHashMap** 继承后重写这些回调，即可在 HashMap 原始操作基础上增加额外处理（如维护插入/访问顺序）。

## resize 扩容

`resize()` 同时承担**初始化**与**扩容**两种职责：

```java
final Node<K,V>[] resize() {
    Node<K,V>[] oldTab = table;
    int oldCap = (oldTab == null) ? 0 : oldTab.length;
    int oldThr = threshold;
    int newCap, newThr = 0;

    if (oldCap > 0) {                      // 已有数组：扩容
        if (oldCap >= MAXIMUM_CAPACITY) {  // 已达上限，不再扩容
            threshold = Integer.MAX_VALUE;
            return oldTab;
        } else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                   oldCap >= DEFAULT_INITIAL_CAPACITY)
            newThr = oldThr << 1;          // 阈值翻倍
    } else if (oldThr > 0)                 // 构造时暂存的容量
        newCap = oldThr;
    else {                                 // 默认初始化
        newCap = DEFAULT_INITIAL_CAPACITY;
        newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
    }
    if (newThr == 0) {                     // 兜底计算阈值
        float ft = (float)newCap * loadFactor;
        newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                  (int)ft : Integer.MAX_VALUE);
    }
    threshold = newThr;
    Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
    table = newTab;

    if (oldTab != null) {                  // 迁移旧数据
        for (int j = 0; j < oldCap; ++j) {
            Node<K,V> e;
            if ((e = oldTab[j]) != null) {
                oldTab[j] = null;
                if (e.next == null)                    // 单节点：直接重定位
                    newTab[e.hash & (newCap - 1)] = e;
                else if (e instanceof TreeNode)        // 树：split 拆分
                    ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                else {                                 // 链表：拆成 lo/hi 两条
                    Node<K,V> loHead = null, loTail = null;
                    Node<K,V> hiHead = null, hiTail = null;
                    Node<K,V> next;
                    do {
                        next = e.next;
                        // 新容量是旧容量两倍，下标计算多截取一位（只能是 0 或 1）
                        if ((e.hash & oldCap) == 0) {  // 新增位为 0：下标不变
                            if (loTail == null) loHead = e;
                            else loTail.next = e;
                            loTail = e;
                        } else {                       // 新增位为 1：下标 + oldCap
                            if (hiTail == null) hiHead = e;
                            else hiTail.next = e;
                            hiTail = e;
                        }
                    } while ((e = next) != null);
                    if (loTail != null) { loTail.next = null; newTab[j] = loHead; }
                    if (hiTail != null) { hiTail.next = null; newTab[j + oldCap] = hiHead; }
                }
            }
        }
    }
    return newTab;
}
```

关键设计：
- 容量翻倍（`oldCap << 1`），仍是 2 的幂。
- 元素迁移**无需重新计算 hash**：`newCap = 2 * oldCap` 时下标只多截取一位，该位为 0 则下标不变（lo 链表），为 1 则 `新下标 = 旧下标 + oldCap`（hi 链表），判断依据是 `e.hash & oldCap`。
- 链表按此规则一分为二，尾插法拆分，避免 JDK 7 头插法扩容可能导致的环链死循环问题。

## get 流程

```java
public V get(Object key) {
    Node<K,V> e;
    return (e = getNode(key)) == null ? null : e.value;
}

final Node<K,V> getNode(Object key) {
    Node<K,V>[] tab; Node<K,V> first, e; int n, hash; K k;
    if ((tab = table) != null && (n = tab.length) > 0 &&
        (first = tab[(n - 1) & (hash = hash(key))]) != null) {
        // 1. 先比较首节点
        if (first.hash == hash &&
            ((k = first.key) == key || (key != null && key.equals(k))))
            return first;
        // 2. 首节点不匹配且有后继
        if ((e = first.next) != null) {
            if (first instanceof TreeNode)             // 树：走 getTreeNode
                return ((TreeNode<K,V>)first).getTreeNode(hash, key);
            do {                                       // 链表：逐个比较
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    return e;
            } while ((e = e.next) != null);
        }
    }
    return null;  // 未找到
}
```

流程小结：**计算 hash → 定位桶 → 比较首节点（先 hash 后 equals）→ 树走 getTreeNode / 链表顺序遍历 → 未找到返回 null**。

## 树化与反树化

- **触发树化**：put 时链表长度达到 `TREEIFY_THRESHOLD (8)`，调用 `treeifyBin`。但 `treeifyBin` 内部会先检查数组容量：若 `table.length < MIN_TREEIFY_CAPACITY (64)`，**先扩容而不是树化**——桶太少时树化收益低，扩容分散元素更划算。
- **树拆分**：扩容时红黑树节点调用 `TreeNode.split`，按 `(e.hash & oldCap)` 拆成 lo/hi 两部分；任一部分节点数 ≤ `UNTREEIFY_THRESHOLD (6)` 时退化为链表。
- **阈值为什么是 8/6**：`TREEIFY_THRESHOLD` 取 8 依据泊松分布，负载因子 0.75 下链表长度达到 8 的概率极低（约千万分之六），树化只是应对极端冲突的兜底；反树化阈值取 6 而非 8，中间留出缓冲，避免元素在 7~8 之间频繁增删导致反复树化/退化。

## 面试要点总结

1. **两个参数**：初始容量（桶数量/数组大小）与负载因子（数组最大填充密度，默认 0.75）；键值对数量 > 容量 × 负载因子时扩容。
2. **构造方法不建数组**：底层数组在首次 put 时由 `resize()` 创建（懒加载）。
3. **resize 兼具初始化与扩容**：两种情况都要 new 新数组并赋给 `table`；扩容时旧元素按 `hash & oldCap` 拆成 lo/hi 两条链表，下标不变或 +oldCap，无需重算 hash。
4. **put 主流程**：定位下标 → 空桶直接放 → 键相同覆盖 → 树节点走树插入 → 链表尾插（超阈值树化）→ 超阈值扩容。
5. **get 主流程**：定位桶 → 首节点命中即返回 → 否则树查找或链表遍历；判等先 `hash` 后 `equals`。
6. **允许 null**：null 键 hash 为 0，落在 0 号桶。
7. **非线程安全**：多线程场景需 `ConcurrentHashMap` 或外部同步。

> 来源：鱼皮·编程导航 / codefather — 《面试超高频考点：HashMap 源码逐行解析》
