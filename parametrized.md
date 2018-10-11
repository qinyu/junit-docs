# 单元测试参数化(讲义)

在单元测试的过程中，我们会遇到一些测试案例：

1. 它们的测试逻辑都是一样的
2. 不同的是测是的条件和期望值

测试逻辑可抽象成一个测试模板，再提供给他一组测试数据让模板分别执行。我们可以利用参数化的测试用例。

## JUnit 4 示例

```java
import static org.junit.Assert.assertEquals;

import java.util.Arrays;
import java.util.Collection;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;

// 使用 Parameterized 这个 Runner
@RunWith(Parameterized.class)
public class FibonacciTest {

    // 参数使用公共的静态方法构造，返回一个数组的集合
    @Parameters
    public static Collection<Object[]> data() {
        return Arrays.asList(new Object[][] {     
                 { 0, 0 }, { 1, 1 }, { 2, 1 }, { 3, 2 }, { 4, 3 }, { 5, 5 }, { 6, 8 }  
           });
    }

    // 成员变量作为测试的参数
    private int fInput;

    private int fExpected;
　
    // 参数通过公共的构造方法注入
    public FibonacciTest(int input, int expected) {
        this.fInput = input;
        this.fExpected = expected;
    }

    // 测试方法不能you参数
    @Test
    public void test() {
        // 测试方法中使用成员变量作为测试的参数
        assertEquals(fExpected, Fibonacci.compute(fInput));
    }
}
```

```java
public class Fibonacci {
    public static int compute(int n) {
        int result = 0;
    	
        if (n <= 1) { 
            result = n; 
        } else { 
            result = compute(n - 1) + compute(n - 2); 
        }
        
        return result;
    }
}
```

## JUnit 4 参数化的问题

1. 必须使用 Parameterized，无法和其它 Runner(如SpringJUnitRunner)一起使用。
2. 不能为单个测试方法提供参数，参数只能赋值给成员变量
3. 提供参数的方法比较单一，如果要从文件中读取数据，需要花时间开发一个简单的工具方法。
4. 参数定义，生成，使用点分散，可读性较差

## JUnit 5 参数化示例

首先需要添加依赖

```xml
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter-params</artifactId>
    <version>5.2.0</version>
    <!--避免测试的依赖被打进交付件-->
    <scope>test</scope>
</dependency>
```

和JUnit 4最大的区别是：参数化的对象由“类”变成了“方法”。

```java
// 参数化 Annotation 标注在方法上
@ParameterizedTest
// 参数也是提供给单个方法
@ValueSource(strings = { "Hello", "JUnit" })
void withValueSource(String word) {
    assertNotNull(word);
}
```

JUnit 5 还提供了多种提供给参数的方式

```java
// @ValueSource 注解可以提供四种**单个**(四选一)参数的值
String[] strings()
int[] ints()
long[] longs()
double[] doubles()
```

```java
// 对所有枚举的值进行测试
@ParameterizedTest
@EnumSource(TimeUnit.class)
void withAllEnumValues(TimeUnit unit) {
    // executed once for each time unit
}

// 对指定枚举的值进行测试
@ParameterizedTest
@EnumSource(
    value = TimeUnit.class,
    names = {"NANOSECONDS", "MICROSECONDS"})
void withSomeEnumValues(TimeUnit unit) {
    // executed once for TimeUnit.NANOSECONDS
    // and once for TimeUnit.MICROSECONDS
}
```

也可以支持多个参数

```java
@ParameterizedTest
// 指定生成参数的方法
@MethodSource("createWordsWithLength")
void withMethodSource(String word, int length) { }

// 静态方法无法嵌套！
// 返回泛型类型为Arguments的Iterable
private static Stream<Arguments> createWordsWithLength() {
    return Stream.of(
        // Arguments.of 生成一套参数
        Arguments.of("Hello", 5),
        Arguments.of("JUnit 5", 7));
}
```

```java
@ParameterizedTest
// 使用Csv格式的字面值组织参数，每个字符串对应csv文件中的一行，一行是一套逗号隔开的参数
@CsvSource({ "Hello, 5", "JUnit 5, 7", "'Hello, JUnit 5!', 15" })
void withCsvSource(String word, int length) { }


@ParameterizedTest
// 或者把参数存放在单独的文件中
// 资源文件应该放在 test/resources 目录下，建议目录结构和 package 一致
@CsvFileSource(resources = "word-lengths.csv")
void withCsvSource(String word, int length) { }
```

做测试时，一般需要把一个字符串转换成一个其它类型的参数。

```java
enum Summer {
    JUNE, JULY, AUGUST, SEPTEMBER;
}

@ParameterizedTest
@CsvSource({"true, 3.14159265359, AUGUST, 2018, 2018-08-23T22:00:00"})
void testDefaultConverters(
    // 基本类型会调用 valueOf 转换
    boolean b, 
    double d, 
    // 枚举调用 valueOf 转换
    Summer s,
    // 调用对应的 parse 方法转换
    Year y, 
    // 时间格式支持 ISO 8601
    LocalDateTime dt) { }


@ParameterizedTest
@CsvSource({"true, 3.14159265359, AUGUST, 2018, 23.08.2018"})
void testDefaultConverters(
    boolean b, double d, Summer s, Year y,
    // 自定义时间格式的转换
    @JavaTimeConversionPattern("dd.MM.yyyy") LocalDate dt) { }
```

或者提供一个接受单个字符串参数的静态工厂方法

```java
public class Point {
    // 接受单个字符串的静态工厂方法
    public static Point from(CharSequence string) {
        /*...*/
    }
}

@ParameterizedTest
@ValueSource(strings = { "(0/0)", "(0/1)","(1/1)" })
// 会自动找到 Ponit 类的工厂方法
void convertPoint(Point point) { }
```

或者提供自定义的转换器(除了可以转换字符串，还可以转换其它类型的单个参数)

```java
// 实现 ArgumentConverter 类
public class PointConverter implements ArgumentConverter {

    // 重写 convert 方法
    @Override
    public Object convert(
            Object input, ParameterContext parameterContext)
            throws ArgumentConversionException {
        if (input instanceof Point)
            return input;
        if (input instanceof String)
            try {
                return Point.from((String) input);
            } catch (NumberFormatException ex) {
                String message = input
                    + "is no correct string representation of a point.";
                throw new ArgumentConversionException(message, ex);
            }
        throw new ArgumentConversionException(input + "is no valid point");
    }
}

@ParameterizedTest
@ValueSource(strings = { "(0/0)", "(0/1)","(1/1)" })
void convertPoint(@ConvertWith(PointConverter.class) Point point) { }
```

如和要把多个字符串转换成一个对象

```java
@ParameterizedTest
@CsvSource({ "0, 0, 0", "1, 0, 1", "1.414, 1, 1" })
// 通过 ArgumentsAccessor 获取多个参数
void testPointNorm(double norm, ArgumentsAccessor arguments) {
    Point point = Point.from(
    // arguments 包含了所有参数
    arguments.getDouble(1), arguments.getDouble(2));
    /*...*/
}
```

```java
@ParameterizedTest
@CsvSource({ "0, 0, 0", "1, 0, 1", "1.414, 1, 1" })
void testPointNorm(
    double norm,
    @AggregateWith(PointAggregator.class) Point pointA,
    @AggregateWith(PointAggregator.class) Point pointB) {
    /*...*/
}

// 将多个参数转换成一个对象
static class PointAggregator implements ArgumentsAggregator {
 
    @Override
    Object aggregateArguments(
        ArgumentsAccessor arguments, ParameterContext context)
            throws ArgumentsAggregationException {
        return Point.from(
            arguments.getDouble(1), arguments.getDouble(2));
    }

}
```

