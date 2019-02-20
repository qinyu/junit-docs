# 测试替身(讲义)

用来替换被测系统的依赖的等价实现。

![](http://xunitpatterns.com/Test%20Double.gif)

那些依赖需要替换？

1. 没有返回结果，也没有状态变化
2. 还没有实现的代码
3. 速度慢，不稳定(IO、网络、异步、生产或测试数据库)
4. 准备起来十分困难（较大的文件）

##  替身的种类

![](http://xunitpatterns.com/Types%20Of%20Test%20Doubles.gif)

1. Dummy，为了让测试可以进行，不会在测试中使用，一般用来填充参数
2. Stub，为测试中的调用提供事先准备好的返回数据
3. Spy，记录如何依赖在测试中如何被调用，包括次数、顺序、传入参数
4. Fake，是一种真正的实现，但和生产环境实现不同，往往是简化实现(如内存数据库 H2)
5. **Mock**，使用库自动生成的替身，可以完成 Stub 和 Spy 的功能。

单元测试经常使用的是 Dummy 和 Mock

## 原则

1. 尽量别用 Mock(stub)，优先使用正真的实现（**！！尤其重要！！**）
2. 不是自己写的类尽量别使用 Mock，不要 Stub 不确定的行为
3.  不要 Mock 被测类，只 Mock 它们的依赖

## Mockito 入门

最流行的 Java Mock 框架

https://static.javadoc.io/org.mockito/mockito-core/2.21.0/org/mockito/Mockito.html

### 依赖

- JUnit 4

```xml
<dependency>
  <groupId>org.mockito</groupId>
  <artifactId>mockito-all</artifactId>
  <version>1.10.19</version>
  <scope>test</scope>
</dependency>
```

- JUnit 5

```xmli
```

### 静态导入

> Eclipse 需要导入进入`Preference -> Java -> Editor -> Content Assist -> Favorites`，点击`New Type...`分别加入如下类型：

```java
import org.mockito.BDDMockito.*;
import org.mockito.Mockito.*;
```

### 创建 Mock

> 任何需要 mock 的时候

```java
mock(SomeClass.class)
```

> @Mock 配合 MockitoRule 自动 Mock

```java
@Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

@Mock private SomeClass someMock;
```

### Verification

验证方法是否按期望被调用

```java
// 方法被调用
verify(mockWebService).logout()
// 方法只被调用了一次
verify(mockWebService, times(1)).logout(); // 最少，最多，从不
// 有参数的方法被调用--使用 Macther
verify(mockWebService).login(anyString());
// 有具体参数的方法被调用
verify(mockWebService).login("aUser")；
// 试试多个参数!!!
verify(mockWebService).login("aUser", anyString()); // 要么全部具体值，要么全部使用 Macther
// 检查调用的顺序
InOrder inOrder = inOrder(mockWebService);
inOrder.verify(mockWebService).login();
inOrder.verify(mockWebService).logout();

// BDD 风格(Given)
then(mockWebService).should(times(1)).logout();
```

### Stub

> Mock 对象始终返回方法返回类型的默认值，不会调用  方法的实现

```java
// 始终返回某个值
when(mockWebService.isOffline()).thenReturn(true);
// 按顺序轮流返回一组值
when(mockWebService.isOffline()).thenReturn(true, false, true);
// 抛出异常
when(mockWebService.isOffline()).thenThrow(SomeException.class); //如何实现先返回 True，再抛异常？
// 非类型安全的写法!!!
doReturn(true).when(mockWebService).isOffline();

// BDD 风格(Given)
given(mockWebService.isOffline()).willReturn(true);
```

### 验证参数

> 验证传递给方法的参数是否符合预期

```java
...
// Captor 通常和 Verify 放在一起!!!
ArgumentCaptor<String> userCaptor = ArgumentCaptor.forClass(String.class);
verify(mockWebService).login(userCaptor.captor())；
assertThat(userCaptor.getValue()).isEqualTo("aUser")
```

> 泛型类型的参数

```java
// @Captor 配合 MockitoRule
@Captor ArgumentCaptor<List<String>> userCaptor;
```

### static 方法和 final 方法

1. 使用包装类进行封装(**推荐**)
2. 使用 Mockito 2.x!!!(**慎重**)
3. 使用 PowerMock 扩展!!!(** 慎重**)

### 内部创建的依赖

没有可以注入 Mock 的地方

1. 提供使用该依赖作为参数的构造函数(**推荐**)
2. 提供 package 可见的 setter
3. 使用反射!!!(**慎重**)
