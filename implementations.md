## 测试实现

每个测试方法应该按照用户故事中的验收提交分为 Given\When\Then 三段；先设置前置条件，然后执行被测方法，最后验证方法结果。

```java
@Test
public void should_do_something_if_some_condition_fulfills() {
    // Given 设置前置条件

    // When 执行被测方法

    // Then 验证方法结果
}
```

建议使用`// Given`、`// When`和`// Then`的注释把三段代码隔开。可以修改生测测试的代码模板，在生成测试方法代码的同时也加上这些注释。有些较简单的测试可能把三个步骤全部或部分合并在一起，这种情况下不必严格按照这种“三段”强制要求，请酌情调整。

```java
// Given（创建对象 GreetingController）/When（调用方法 greeting）/Then （assertThat） 全部在一行中
assertThat(new GreetingController().greeting("Heaton"), is(new Greeting(8, "Hello, Heaton!")));
```


### 一个测试方法代码示例

下面是一个测试方法的示例，按照命名规则进行命名并把测试方法中的代码分成了三段，具备一定可读性。

```java
@Test
  public void should_transfer_from_one_account_to_other_account_of_same_user() {
    // Given
    TransferController transferController = new TransferController(accountStorage);

    List<Account> userHeatonAccounts = accountStorage.findByUser("heaton");
    TransactionAccount fromAccount = new TransactionAccount(userHeatonAccounts.get(0).getNumber(),
        userHeatonAccounts.get(0).getBalances().get(0).getCurrency());
    TransactionAccount toAccount = new TransactionAccount(userHeatonAccounts.get(1).getNumber(),
        userHeatonAccounts.get(1).getBalances().get(0).getCurrency());
    Transaction transaction = new Transaction(fromAccount, toAccount, new BigDecimal(500));

    // When
    transferController.transfer(transaction);

    // Then
    assertThat(userHeatonAccounts.get(0).getBalances().get(0).getAmount(), is(new BigDecimal(99500)));
    assertThat(userHeatonAccounts.get(1).getBalances().get(0).getAmount(), is(new BigDecimal(200500)));
  }
```


### 前置条件

一般包括对象创建、Mock 对象行为设置、对象属性设置、文件读取、数据库数据准备等等。

和同一个对象相关的创建和设置代码放在一起，和其他对象的创建及设置代码用空行隔开

前面例子中完成被测方法的调用需要两个条件（`transferController`和`transaction`），所以`// Given`后包含了两段代码分别初始化两个变量

除了在每个测试方法里去准备前置条件，还有其它地方可以做准备；如成员变量、`@Before`和`@BeforeClass`注解的方法以及`TestRule`它们更适合符合以下两种场景：

1. 重复出现在多个测试方法中的准备工作，可以提取出来放在`@Before`和`@BeforeClass`注解的方法准备；如果所有的测试方法都需要的对象可以声明成测试类的成员变量。
2. 在测试之前`@Before`和`@BeforeClass`注解方法中准备好，并需要在测试完成之后在`@After`和`@AfterClass`注解的方法里清理掉或者释放的资源（文件）；


```java
// 使用 TestRule 创建临时文件夹，测试之后会保证删除

@Rule
public TemporaryFolder folder= new TemporaryFolder();

@Test
public void testUsingTempFolder() throws IOException {
    File createdFile= folder.newFile("myfile.txt");
    File createdFolder= folder.newFolder("subfolder");
    // ...
}
```

### 调用被测方法

使用准备好的对和参数用调用被测方法，一般只会调用一个方法一次。

### 验证测试结果

使用断言对测试结果进行验证，一般的验证方法是断言结果是否符合期待（一般是布尔表达式）。测试的结果一般有如下几类：

1. 方法直接的返回值，调用方法产生的结果；直接对结果进行断言

```java
assertThat(greetingController.greeting("Heaton"), is(new Greeting(8, "Hello, Heaton!")));
```

2. 被测方法调用过程中产生的“副作用”，包括方法内对依赖对象（如被测对象，被测对象的成员变量，方法参数等）状态（成员变量）的修改；也要对这些对象的状态进行断言

```java
// When 方法没有直接返回记过
transferController.transfer(transaction);

// Then 验证方法调用中产生的"副作用"
assertThat(userHeatonAccounts.get(0).getBalances().get(0).getAmount(), is(new BigDecimal(99500)));
```

3. 被测方法执行过程中回调了监听器或观察者的回调方法；要断言回调方法是否被调用到，还要验证回调方法收到的消息（参数）是否正确

```java
// Given 设置观察者
...
Observer<Book> observer = mock(Observer.class);
TestSubscriber testSubscriber = new TestSubscriber<>(observer);

// When 执行调用观察者回调的方法
searchEngine.search("google").subscribe(testSubscriber);

// Given 验证回调方法被使用正确的参数调用
then(observer)
    .should(times(2))
    .onNext(any(Book.class));
```


4. 被测方法应该抛出某种异常；要断言异常被抛出，如有必要，还要断言异常的细节（如消息、调用堆栈等）

```java
// 断言执行过程中抛出了异常
@Test(expected = IllegalArgumentException.class)
public void should_get_account_by_given_non_existing_account_number() {
    assertThat(accountStorage.findByAccountNumber("4001"), is(nullValue()));
}
```

断言使用 Hamcrest 库，见下面介绍