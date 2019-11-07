# 单元测试基础(讲义)

## 测试框架示意图

![](http://xunitpatterns.com/Four%20Phase%20Test.gif)

---

##  术语

- Test Runner -- 测试执行器，可以创建测试套件(对象)并执行其中的测试对象的一个应用程序(IDE、命令行构建脚本)。
- **Test (Case) Class/Object** -- 测试(用例)类/对象，包含一组相关的测试方法。
- **Test Method** -- 测试方法，独立的一个完整测试
- Test Suite (Object) -- 测试套件(对象)，一个测试的集合接口，用来执行一组相关的测试对象
- **SUT** -- 被测系统，代表我们要测试的功能
- **Fixture** -- 测试桩，测试的上下文，是被测系统运行需要的环境

---

## 步骤

1. Fixture Setup -- // Given，环境准备(创建和注入依赖或者替身，创建对象)
2. Exercise SUT -- // When，执行方法(调用被测方法)
3. **Result Verification** --// Then，验证结果(方法返回值和副作用)
4. Fixture Teardown -- // 环境清理(避免测试之间互相影响)

---

## 原则

**F**ast(快)，单元测试要运行的足够快，单个测试方法一般要立即（一秒之内）给出结果

> 要测试运行得快，要减少一些费时的操作（比如 I/O），用测试替身代替。测试足够快，才会更有意愿编写测试，甚至代替大部分调试工作

**I**dependent(独立)，测试方法之间不要有依赖（先执行某个测试方法，再执行另一个测试方法才能通过）

> 多数测试框架默认测试方法执行是无序的。这样可以只用执行一个或是部分测试方法（不如分组并行执行提升效率）

**R**epeatable（重复），可以在本地或 CI 不同环境（机器上）上反复执行，不会出现不稳定的情况  
**S**elf-Validating（自验证），测试成功或失败不应该通过日志来定位问题

> 测试必须包含断言，断言尽可能地精确。

**T**imely（及时），测试至少应该和实现代码一起编写，甚至提前编写

除此之外，测试代码应该具备最好的**可读性**和最少的**维护代价**，绝大多数情况下写测试应该就像用**专用语言描述一个事实，不用思考就知道这个测试描述的具体场景**。

---

## JUnit 示例

Top1 Java 库，Java 项目中最常用的单元测试框架，各种开源项目和工具都支持，也有不少扩展。目前最新版本是 JUnit 5，相对 JUnit 4 变化比较多，增加了许多新的方便的特性：

1. 扩展更灵活，和 Junit 之前的 TestRule 以及 Runner 相比，限制更少，扩展点更多
2. Tag，增强了 Categorized 的功能，可以更加灵活的组织测试
3. 更加方便灵活地参数化测试，支持多种参数提供方式

即使项目中已经存 Junit 3 或者 4 编写的单元测试，JUnit 5 也可以执行它们（只需要少量修改）。

下面分三个阶段介绍实施单元测试要做的一些工作

### 第一步，项目准备

包括在项目中加入 JUnit 框架，组织测试目录，以及对应的 IDE 配置。

#### MAVEN 配置

```xml
<dependencies>
    ...
    <!--编写 JUnit 5 测试需要的基础类、接口、注解-->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter-api</artifactId>
        <version>5.3.1</version>
        <scope>test</scope>
    </dependency>
    <!-- Maven surefire 和 failsafe 插件执行 JUnit 5 测试需要的引擎 -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter-engine</artifactId>
        <version>5.3.1</version>
        <scope>test</scope>
    </dependency>
    ...
</dependencies>
<build>
    <plugins>
    ...
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-surefire-plugin</artifactId>
            <!--必须使用 2.22.0 以上的版本才支持执行 JUnit 5 编写的单元测试-->
            <version>2.22.0</version>
        </plugin>
    ...
    </plugins>
</build>
```

#### 包含测试的项目目录结构

默认的 maven 目录结构，不需要外的配置。如不采用默认目录结构，测试代码以及资源应该和源代码分开存放在不同的目录中，避免打包时将测试代码和资源打入最终交付件。

```sh
├── pom.xml
├── src
│   ├── main # 源代码根目录
│   │   ├── java # 被测代码所在目录
│   │   └── resources # 项目资源所在目录
│   └── test # 测试根目录
│       └── java # 测试代码目录
│       └── resources # 测试资源目录
```

#### IDE 设置

IDE 的模板和静态导入配置，见其它文档。

### 第二步，编写测试

每个测试方法应该按照用户故事中的验收提交分为 Given/When/Then 三段；先设置前置条件，然后执行被测方法，最后验证方法结果。

方法名应该准确的表示测试的场景，建议：

1. 使用 `should` 开头
2. 使用下划线 `_` 隔开单词

```java
@Test
public void should_do_something_if_some_condition_fulfills() {
    // Given 设置前置条件

    // When 执行被测方法

    // Then 验证方法结果
}
```

建议使用`// Given`、`// When`和`// Then`的注释把三段代码隔开。可以修改生测测试的代码模板，在生成测试方法代码的同时也加上这些注释。有些较简单的测试可能把三个步骤全部或部分合并在一起，这种情况下不必严格按照这种“三段”强制要求，请酌情调整。

#### 准备和清理

1. 每个测试方法都需要的准备和清理工作，可以提取出来放在`@Before`和`@After`注解的方法准备；所有的测试方法都需要的对象可以声明成测试类的成员变量。也可以使用`@Rule`将准备和清理工作剥离出来。
2. 整个测试类需要执行一次的准备和清理工作，在`@BeforeClass`和`@AfterClass`注解的方法中实现。也可以使用`@ClassRule`将准备和清理工作剥离出来。
3. 熟悉一些常用的 TestRule，如 MockitoRule、TemporaryFolder、RuleChain 等等

### 第三步，执行测试

1. 在 IDE 里执行

   - 按测试方法、测试类、测试目录执行或全部执行
   - 测试结果查看(查看代码覆盖率)
     > IDE 演示，代码覆盖率讲解

2.  用命令行执行(以 Maven 为例)

   供持续集成和提交前检查使用的脚本

   命令 `mvn -Dtest=SomeTest#should test`

   参考文档：[Maven Surefire 插件](https://maven.apache.org/surefire/maven-surefire-plugin/examples/junit.html)

### 测试用例的组织

1. 一个测试方法对应一条测试用例

   一个被测方法可以对应多个测试方法（多条测试用例，不同的条件）

2. 一个测试类对应一个或多个被测类（测试类和被测类放在同一个）

   一个被测类对应多个测试类（当一个测试类中的测试方法太多，影响可读性时可以拆分，拆分的方式可以灵活掌握，如按场景、按优先级等等，或是配合测试套件拆分）

3. 使用测试套件将具有相关性的测试类组织在一起（组合的方式可以灵活掌握)

4. 使用 Tag （JUnit 5）将具有相关性的测试方法组织在一起


