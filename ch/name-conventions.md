## 命名规范（推荐）

### 目录

单元测试代码应该和被测代码处在同一个项目中，符合Maven标准的项目目录结构，测试代码和被测代码分开，避免测试代码被打包到制品内。

```sh
src #源代码目录
├── main/
│   ├── java/ #被测代码
│   └── resources/
└── test/
    └── java/ #测试代码目录
```

### 包

单元测试类和被测类在同一个包中（尽管在不同目录），每个测试类对应一个被测类，目的是为了测试一些包内可见的方法，不破坏封装的同时覆盖更多方法

集成测试类（跨多个类的测试）不需要和测试类一一对应，也可以使用单独的包

### 文件

单元测试文件（类）名应为被测文件（类名）加上 Test 后缀结尾，如：被测类名为`SomeClass`，则对应测试类为`SomeClassTest`

集成测试文件（类）命名以`IT`结束，如`MultipleClassesIT`

> 以上命名规则是`maven-surefire-plugin`和`maven-failsafe-plugin`关于单元测试和集成测试命名的默认约定。

### 方法

每个测试方法应该清楚的说明当前测试方法的验证的结果和成立的条件，应该是以`should`开头一个短句。这样的测试名字会提醒开发专注于当前的测试场景，也更易读。示例如下：

```java
@Test
public void should_do_something_if_some_condition_fulfills() {
    // test implementation
}
```

> 可以利用 IDE 的代码模板功能提前写好模板使用快捷键插入

除了测试方法以外还有准备（setUp）和销毁（tearDown）两个方法，又分为静态（整个类中所有测执行前后调用）的和非静态（每个测试方法执行前后调用）的，按照 JUnit 习惯命名就好

```java
@BeforeClass
public static void setUpBeforeClass() throws Exception {
    // 类中所有测试方法执行之前调用
}

@AfterClass
public static void tearDownAfterClass() throws Exception {
    // 类中所有测试方法执行之后调用
}、

@Before
public void setUp() throws Exception {
    // 每个测试方法执行之前调用
}

@After
public void tearDown() throws Exception {
    // 每次测试方法执行之后调用
}

// 其它代码...
```

> 推荐使用 snake_case 形式（单词全小写，单词之间下划线隔开），这样断句更清晰，也少摁很多`Shift`键。

### 变量

测试代码中的变量名没有特殊，和被测代码中的变量名保持一样的规则。

> 如果使用 IntelliJ，可以先写出变量赋值语句的右边，如`new SomeClass()`或者`someObject.getSomeProperty()`，再使用 Extract -> Local Variable/Field/Constant/Parameter 等重构手法提取变量，IntelliJ 自动推荐的命名是非常号的参考，可以直接使用。

测试代码中遇到的另一类常见的对象是使用 Mock工具 创建的对象，又分为 Mock 对象和 Spy 对象，相应的变量名前需要加上`mock`或`spy`前缀以示区分，如`mockSomeInterface`或者`spySomeObject`。