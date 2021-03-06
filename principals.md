# JUnit 单元测试规范

## 原则（F.I.R.S.T）

**F**ast(快)，单元测试要运行的足够快，单个测试方法一般要立即（一秒之内）给出结果  
**I**dependent(独立)，测试方法之间不要有依赖（先执行某个测试方法，再执行另一个测试方法才能通过）  
**R**epeatable（重复），可以在本地或CI不同环境（机器上）上反复执行，不会出现不稳定的情况  
**S**elf-Validating（自验证），测试成功或失败不应该通过日志来定位问题  
**T**imely（及时），测试至少应该和实现代码一起编写，甚至提前编写  

除此之外，测试代码应该具备最好的**可读性**和最少的**维护代价**，绝大多数情况下写测试应该就像用**领域特定语言描述一个事实**，甚至**不用经过仔细地思考**。

