# 贡献指南

## 开发环境

- 言序 1.1.12；
- Git；
- 带 JSON 与 Pathname 标准库的 Ruby（运行文档覆盖门禁）；
- 不需要数据库、网络服务或原生工具链。

不要把令牌、Cookie、私有地址或真实用户 HTML 样本提交到仓库。安全问题请先按 [SECURITY.md](SECURITY.md)私下报告。

## 锁文件

包解析和缓存命令必须串行运行：

```sh
yanxu 包 更新 .
yanxu 包 锁 --离线 .
yanxu 包 更新 examples
yanxu 包 锁 --离线 examples
yanxu 包 更新 benchmarks
yanxu 包 锁 --离线 benchmarks
```

示例和基准通过路径依赖引用根包。根包源码、文档、清单或其他受跟踪内容变化后，它们的内容校验和也会变化，须重新生成两份消费者锁。

## 本地检查

格式和静态检查：

```sh
find src tests examples benchmarks -name '*.yx' -exec yanxu 格 --写 {} \;
find src tests examples benchmarks -name '*.yx' -exec yanxu 查 {} \;
yanxu 试 tests --json
yanxu 文 --json src/言序HTML.yx /tmp/yanxu-html-api.json
ruby scripts/verify_docs.rb /tmp/yanxu-html-api.json .
```

示例与 Release 构建：

```sh
yanxu 字节 examples/组件.yx
yanxu 字节 examples/增量页面.yx
yanxu 编 . --release -o /tmp/yanxu-html.yxb
yanxu 编 examples --release -o /tmp/yanxu-html-example.yxb
yanxu 行 /tmp/yanxu-html-example.yxb
```

基准必须保留实际负载与结果校验：

```sh
yanxu --max-steps 10000000 字节 benchmarks/安全渲染性能.yx -- 50
yanxu 编 benchmarks --release -o /tmp/yanxu-html-benchmark.yxb
yanxu --max-steps 10000000 行 /tmp/yanxu-html-benchmark.yxb -- 50
```

不要提交只计时的空循环，也不要把某台机器的毫秒数当成跨平台性能承诺。

## 设计要求

- 不可信值只能进入`文字`或受验证的属性；
- 新标签或属性策略必须解释解析上下文，并覆盖大小写、控制字符和重复输入；
- 新 URL 属性必须进入统一协议检查，不能在调用方文档中靠约定补救；
- 可信扩展仍须通过渲染状态写入，不能公开底层收集器或绕过预算；
- 输入列和公开读取结果须保持快照隔离，不泄露内部可变列；
- 新资源配置须有默认值、硬上限、稳定错误码和边界规格；
- 流式路径与完整路径必须复用同一渲染器，并校验联结结果一致；
- 失败代码是兼容协议，消息只用于诊断。

## 测试范围

行为变化至少覆盖正常路径、边界、无效输入、资源限制和错误代码。安全策略变化还要覆盖大小写变体、控制字符、属性重复、可信接口和完整页面快照。

文档示例必须只使用公开 API。API 增删或改名时同步更新 `docs/API.md`、迁移说明和机器清单覆盖门禁。

## 提交与审查

每个可独立验证的行为使用单独提交。提交前检查：

```sh
git status --short
git diff --check
git diff --cached
```

拉取请求应说明安全边界、兼容性、迁移影响、测试命令、基准负载和依赖变化。使用普通合并保留各步骤提交，不重写已经共享的历史。
