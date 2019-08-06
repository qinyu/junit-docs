# 可测试性代码规范

软件的可测试性是指在一定的时间和成本前提下，进行测试设计、测试执行以此来发现软件的问题，以及发现故障并隔离、定位其故障的能力特性。简单的说，软件的可测试性就是一个计算机程序能够被测试的容易程度。

软件的可测试性和以下因素有关：

- **可控制性**：是否可以将被测组件的状态控制到如测试条件要求。
- **可观察性**：是否可以观察（中间或最后的）测试结果。
- **可隔离性**：被测组件是否可以隔离测试。
- **关注点分离**：被测组件是否有单一且清楚定义的任务。
- **易懂性**：被测组件是否有说明文档，或是本身可读性很高。
- **可自动化性**：被测组件是否可以自动测试。
- **异质性**：是否需要不同的测试方法及工具平行测试。

若软件的可测试性低，可能会造成测试工作的增加。

# 总则

可测试性代码规范是对基本代码规范的增强和补充，并非只遵守二者中的一个，应该遵守两者的合集。如果可测试性代码规范和基本代码规范出现冲突，请以要求更高更严格的一份规范为准。

代码可测试性低主要表现为：

- 被测对象及其依赖难以构造
- 被测对象的依赖无法设置
- 被测对象的测试结果难以获取
- 被测对象的逻辑复杂难以创造测试条件
- 被测对象依赖不可控的代码
- 被测对象行为描述不清难以理解
- 被测对象行为不确定具有随机性

如遇未在以下规则中覆盖的代码应避免出现上述情形，或者符合软件可测试性要求的因素（见上节）。

# 规则文档说明

一条规则最多包含以下四项说明。每项说明可能提供代码示例进行说明。

**应当** 必须遵照此建议编写代码。

```java
// 应当如此
public class ShouldAlwaysDoThis {}
```

**尽量** 尽可能按照次建议编写代码，如果你对背后原理十分清楚，又有其它限制，注释清楚后可以选择不遵守。

```java
// 尽量如此
public class DoThisIfPossible {}
```

**避免** 避免出现这样的代码。

```java
// 避免如此
public class DoNotDoThis {}
```

**原因** 这些建议背后的原因说明。

# 1. 控制反转

## 1.1 不要在非静态内部类内引用外部类成员变量

**避免** 使用私有非静态内部类封装被测行为，以及引用外部类的成员变量。

```java
// 避免如此
public class OuterClass {
    private int outerField;

    private class InnerClass {
        int doCalculate() {
             // 引用外部成员变量
            return outerField * 5;
        }
    }
}
```

**尽量** 使用独立的类，增加成员变量并提供构造方法初始化。

```java
// 尽量如此
public class InnerClass {
    private int innerField;

    public InnerClass(int innerField) {
        this.innerField = innerField;
    }

    int doCalculate() {
        return innerField * 5;
    }
}

// 通过构造方法初始化
assertThat(new InnerCalss(someValue).doCalculate(), ...);
```

**原因** 内部类的被测行为不可见，无法验证；外部类构造复杂影响内部类测试；独立出来的类可以更方便编写独立的单元测试。

## 1.2 不要在非静态内部类内引用外部类成员方法

**避免** 使用私有非静态内部类封装被测行为，以及引用外部类的成员方法。

```java
// 避免如此
public class OuterClass {
    private int outerMethod() {...}

    private class InnerClass {
        int doCalculate() {
             // 引用外部成员方法
            return outerMethod() * 5;
        }
    }
}
```

**尽量** 使用独立的类，增加成员变量引用其他类的行为，并提供构造方法初始化成员变量。其他类的行为应该抽象成接口。

```java
// 尽量如此
// 依赖的外部类的方法抽取成接口
interface OuterInterface {
    public int outerMethod();
}

public class OuterClass implements OuterInterface {
    public int outerMethod() {...}
}

// 使用独立的类
public class InnerClass {
    private OuterInterface outerInterface;

    // 依赖抽象的接口
    public InnerClass(OuterInterface outerInterface) {
        this.outerInterface = outerInterface;
    }

    int doCalculate() {
        return outerInterface.outerMethod() * 5;
    }
}

// 在测试中使用Stub或者mock
assertThat(new InnerCalss(new OuterInterface(){
    public int outerMethod() {...}
}).doCalculate(), ...);
```

**原因** 内部类的被测行为不可见，无法验证；外部类构造复杂影响内部类测试，使用抽象接口解除对外部类的依赖；独立出来的类可以更方便编写独立的单元测试；使用抽象接口避免循环依赖。

## 1.3 提供带参数的构造方法便于注入依赖

## 1.4 将变量初始化放到构造方法中

## 1.5 将依赖变成方法参数

## 1.6 用 getter 代替单例变量

## 1.7 为控件设置固定的 id 或 description

## 1.8 遵循 id 和 description 规范

## 1.9 将线程中的逻辑独立出来

## 1.10 将数据库操作抽象成接口

## 1.11 将文件操作抽象成接口

# 2. 降低复杂度

## 2.1 避免嵌套条件语句

## 2.2 封装复杂的条件判断

## 2.3 提供 builder 方便复杂对象的构造

# 3. 保证可读性

## 3.1 方法签名应当表达准确

**应当** 为方法提供准确的名字（建议使用动词开头）描述方法的作用，方法参数也应当有清晰的名字说明参数的作用。

## 3.2 建议公共元素提供 JavaDoc

**尽量** 在编写公共元素（类、接口、方法、常量、成员变量、枚举等）代码的同时编写 JavaDoc。JavaDoc 应遵循相应规范，重要的元素必须说明。

## 3.3 对外提供的接口应当提供文档和代码示例

**应当** 为对外提供的接口编写完善的文档，文档格式依照相关约定（如 Markdown、JavaDoc 等）。

**尽量** 为对外提供的接口编写示例（建议以测试用例的形式提供）。
