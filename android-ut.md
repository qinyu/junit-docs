# Android单元测试指南

### 原理

对象之间通过**消息**沟通，可以**接收**消息，也可以**发出**消息吗，**消息**分两个类型：
1. 查询消息：返回结果，无**副作用**（对象状态不发生变化）
2. 命令消息：不返回结果，有**副作用**（对象状态发生变化）

| 如何测试 |  查询  |  命令  |
| --- | --- | --- |
| 接收 | 断言结果 | 断言**直接可见**的副作用 |
| 发出 | 忽略 | 断言发出的消息符合期望 |
| 内部 | 忽略 | 忽略 |

### mCloud特点

1. 业务相关性少
2. 绝大多数严重依赖Android Framework
3. 实现代码已经编写，可测试性较差，且大动作重构有风险

对于绝大多数API，不能脱离Android Framework进行测试，且对Android Framework进行Stub成本较高，有需要能方便的对对象级别的方法测试，目前的选择使用Android Instrumentation Test。

**下述内容仅针对严重依赖Android Framework的依赖代码**

### 准备工作

1. 创建“测试”module，包含测试代码，以及支持测试代码的Application、Activity等
2. 在“测试”module中增加ATSL的依赖
3. 配置“测试”module使用AndroidJUnitRunner运行测试

```groovy
android {
    defaultConfig {
        testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
    }
}

dependencies {
    androidTestCompile 'com.android.support.test:runner:0.5'
    androidTestCompile 'com.android.support.test:rules:0.5'
    androidTestCompile 'com.android.support.test.espresso:espresso-core:2.2.2'
}
```

### 开始写测试
##### 创建测试类
1. 测试类放在“测试”module的`src/androidTest/java`目录
2. package和被测类**一样**
3. 测试类名字时被测类名字加上Test
4. 测试类声明时加上`@RunWith(AndroidJunit4.class)`的Annotation

```java
import org.junit.runner.RunWith;
...

@RunWith(AndroidJUnit4.class)
public class ApkPluginManagerTest {
...
}
```

##### 创建测试方法

1. 测试方法命名使用下划线`_`隔开单词, 使用should开头，长度不限，表明测试的目的
```java
@Test
public void should_return_package_name() {
}
```
2. 测试方法中的代码分成三段：被测对象准备，调用被测对象方法，断言结果／副作用／发出的消息

##### 被测对象（及其依赖）准备
1. 直接使用构造方法创建
2. 直接获取Singleton
3. 使用工厂方法创建
4. 创建支持Activity/Service等，通过TestRule创建
```java
    @Rule
    public ActivityTestRule<TestActivity> activityTestRule = new ActivityTestRule<>(TestActivity.class);

    @Test
    public void init() throws Exception {
        TestActivity activity = activityTestRule.getActivity();
    }
```

5. 依赖的其他资源需要早支持代码里准备，如AndroidManifest／layout／string／value／image等资源，包括bundle
6. Mock对象（待补充）
7. 被测对象私有成员变量不好修改，可以增加package level的setter或带参数的构造方法，进行注入

##### 调用被测对象方法

方法参数的构造参考参考\[被测对象（及其依赖）准备\](#被测对象（及其依赖）准备)

##### 断言结果／副作用／发出的消息

1. 使用hamcrest提供的matcher实现是一些常见的断言，提高测试代码可读性
2. 必要时实现自己的matcher
3. 如果无法断言副作用，小规模安全的重构，改变测试调用方法
   * 提取方法
   * 提取变量／成员变量
   * 提取接口
   * 移动
   * 重命名
   > 上述方法应使用IDE提供的自动重构菜单项完成，保证可以回滚，避免人为错误

### 万不得已的救命稻草－反射

1. 通过前面重构方法都无法接触耦合活着暴露副作用，活着重构规模太大，风险太高
2. 使用一些方便的库来减少代码编写
```groovy
    dependencies {
        androidTestCompile 'de.jodamob.android:SuperReflect:1.0.1'
    }
```

```java
    Map<String, List<ComponentName>> map = on(apkPluginManager)
        .field("mContainersMap")
        .get();
```

### 其他技巧

1. 熟悉IDE快捷键
   * Ctrl+Shift+T 测试类与被测类之间跳转
   * Ctrl+Shift+F10 运行测试
2. 创建测试方法以及断言的模版
```java
@org.junit.Test
public void should_$RET$() {
    //Given
    $END$
    //When

    //Then
}
```

```java
org.hamcrest.MatcherAssert.assertThat($VAR$, org.hamcrest.core.Is.is($END$));
```

### 参考文档
1. https://codelabs.developers.google.com/codelabs/android-testing/index.html
2. https://google.github.io/android-testing-support-library/
3. http://www.vogella.com/tutorials/AndroidTesting/article.html
