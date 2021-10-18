# 断言结果(讲义)

对被测系统产生的结果进行检查的，通常使用测试框架提供的工具方法完成。

断言包括：

1. 直接给出测试结果(直接失败)
2. 直接断言测试执行的状态(布尔值，非空)
3. 检查结果是否精确匹配期望值(给出期望值)
4. 检查结果是否模糊匹配(给出偏差范围，或是条件)
5. 检查抛出预期异常

![](http://xunitpatterns.com/Assertion%20Method.gif)

断言必须兼顾**可读性**和**开发体验**。

推荐使用 AssertJ

https://joel-costigliola.github.io/assertj/

1. assertThat 方法 和 Fluent 语法更流畅的表达断言
2. 断言失败消息更清晰
3. 内置了丰富的断言方法(包括 BDD 风格)以及它们的文档和示例
4. 可以使用代码自动完成

## AsserJ 入门

https://joel-costigliola.github.io/assertj/assertj-core-quick-start.html

### 添加依赖

> 3.x 只适用于 Java 8 版本，Java 7 要使用 2.x 版本

```xml
<dependency>
    <groupId>org.assertj</groupId>
    <artifactId>assertj-core</artifactId>
    <!-- 3.x 只适用于 Java 8 版本，Java 7 要使用 2.x 版本 -->
    <version>3.11.1</version>
    <scope>test</scope>
</dependency>
```

### 静态导入

> Eclipse 需要增加静态导入类型：进入`Preference -> Java -> Editor -> Content Assist`，勾选`Use static imports (only 1.5 or higher)`

```java
import org.assertj.core.api.Assertions.*;
import org.assertj.core.api.Assertions.*;
```

### 尝试基本类型的断言

> 利用 IDE 的自动完成功能，试试一些不常见的方法

```java
assertThat(anyInt).  // 大于或小于
assertThat(anyString).  // 开始、结束、正则表达式
assertThat(anyDoube).  // offset
assertThat(anyPOJO).  // 部分属性匹配
assertThat(anyMap).  // 键，值
assertThat(anyList).  // 前面几个，最后几个

// 同时满足多种验证(Fluent 语法)
assertThat(anyString).startsWith(...).endsWith
```

### 直接失败

```java
fail(...);
```

### 断言异常

```java
Throwable catchThrowable = catchThrowable(new ThrowableAssert.ThrowingCallable() {
    @Override public void call() throws Throwable {
        // 应该抛出异常的代码
    }
});
assertThat(catchThrowable).

// 简单写法，可以使用 Java 8 lambda
assertThatThrownBy(new ThrowableAssert.ThrowingCallable() {
    @Override public void call() throws Throwable {
        // 应该抛出异常的代码
    }
}).
```

### Soft Assertion

一组连续普通断言中如果中间一个失败，随后的断言都不会执行。

> 试试故意让其中的断言失败，查看错误信息

```java
SoftAssertions softly = new SoftAssertions();
softly.assertThat(mansion.guests()).as("Living Guests").isEqualTo(7);
softly.assertThat(mansion.kitchen()).as("Kitchen").isEqualTo("clean");
...
softly.assertAll();
```

### 断言集合元素的属性

> 试试 POJO 列表的单个属性、多个属性、嵌套属性  
> 再试试 Map 列表

```java
assertThat(anyListOfObject).extracting(aPropertyName).

assertThat(anyListOfObject).extracting(aPropertyName, anotherPropertyName).contains(tuple(aPropertyValue, anotherPropertyValue), ...)
```

### JSON 支持

直接使用 JsonPath 或者 https://github.com/lukas-krecan/JsonUnit#assertj

### 高级特性

1. 自定义条件：https://joel-costigliola.github.io/assertj/assertj-core-conditions.html
2. 自定义断言：https://joel-costigliola.github.io/assertj/assertj-core-custom-assertions.html
3. 断言生成器：https://joel-costigliola.github.io/assertj/assertj-assertions-generator.html#news
