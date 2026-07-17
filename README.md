# 言页

[![CI](https://github.com/yanxulang/yanxu-html/actions/workflows/ci.yml/badge.svg)](https://github.com/yanxulang/yanxu-html/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

言页（`yanxu-html`）是言序的服务端安全 HTML 构造与增量渲染库。它用节点类型区分普通文字、属性、元素、片段、组件、完整文档和受信任扩展，让自动转义成为默认路径，让每个绕过转义的决定在代码中可见。

当前稳定线为 `1.0.x`；本文档对应 `1.0.0` 发布候选。

## 主要能力

- 普通文字和文字属性值自动执行 HTML 转义；
- 标签、属性、URL 协议和空元素使用保守的默认策略；
- 默认拒绝脚本、样式、嵌入、SVG/Math 子语言、事件属性和重复属性；
- 片段、元素和组件可组合，输入列与读取结果使用快照隔离；
- `流式渲染`逐片回调，不先构造完整输出；
- 深度、节点、属性、输出字符和输出片段均有默认预算及硬上限；
- `错误详情`和`尝试渲染`提供稳定的结构化失败协议；
- `原始`和`扩展`提供显式可信边界，并仍受统一输出预算约束；
- 核心为纯言序实现，不申请文件、网络、监听、环境、进程或原生扩展权限。

## 安装

使用言包加入稳定版本：

```sh
yanbao add html --package 言页 --version "^1.0"
```

等价清单：

```toml
[依赖]
言页 = { git = "https://github.com/yanxulang/yanxu-html.git", 修订 = "v1.0.0", 版 = "^1.0" }
```

锁文件会固定提交和内容校验和。应用导入清单中的包名：

```yanxu
引「包:言页」为 HTML；
```

从 0.1.x 的 `yanxu-html` 包名升级时，按[迁移指南](docs/MIGRATION.md)更新依赖键和导入路径。

## 五分钟示例

```yanxu
引「包:言页」为 HTML；

定 页面 为 HTML.文档（
    HTML.元素（「html」，【HTML.属性（「lang」，「zh-CN」）】，【
        HTML.元素（「body」，【】，【
            HTML.元素（「h1」，【】，【HTML.文字（「言序 <Web>」）】），
            HTML.元素（「a」，【HTML.属性（「href」，「/docs」）】，【
                HTML.文字（「阅读 & 学习」）
            】）
        】）
    】）
）；

言 HTML.安全渲染（页面）；
```

输出：

```html
<!doctype html>
<html lang="zh-CN"><body><h1>言序 &lt;Web&gt;</h1><a href="/docs">阅读 &amp; 学习</a></body></html>
```

完整页面可以一次返回，也可以逐片发送：

```yanxu
法 写响应片段（片段：文）：空 则
    # 把片段交给响应写入器。
    归 空；
终

定 统计：典 为 HTML.流式渲染（页面，写响应片段，{
    「最大输出字符」：1048576，
    「最大节点」：5000
}）；
```

`统计`包含`节点数`、`字符数`和`片段数`。回调已经收到的片段不会因后续失败自动撤回，因此 HTTP 层应在发送首字节前完成必要的业务验证。

## 错误处理

公开失败使用稳定的 `HTML_*` 代码。程序应读取代码，不要解析中文消息：

```yanxu
定 结果：典 为 HTML.尝试渲染（页面）；

若 非 结果【「成功」】 则
    定 详情：典 为 结果【「错误」】；
    言 详情【「代码」】；
终
```

也可以在`救`分支中调用`HTML.错误详情（所误）`。详情包含`代码`、`消息`、`源代码`、`类别`、`位置`和`踪迹`。

## 安全边界

不可信文字只能进入`文字`或文字属性。以下调用是显式信任升级：

```yanxu
HTML.原始（「<strong>已审计常量</strong>」）；
HTML.扩展（可信写出器）；
```

它们不执行 HTML 清洗，也不会把不可信内容变安全。两种节点都经统一渲染状态写出，所以字符和片段预算仍然生效。标签、属性、URL 和已允许上下文的完整规则见[安全模型](docs/SECURITY_MODEL.md)。

## 权限与兼容性

言页 1.0 要求言序 `>=1.1.12`和格式 2 清单。包清单不申请任何宿主权限：

```text
文件 = []
网络 = []
TCP监听 = []
UDP绑定 = []
环境 = []
进程 = false
原生扩展 = false
```

支持边界和 1.x 兼容承诺见 [COMPATIBILITY.md](COMPATIBILITY.md)。

## 已知限制

- 不解析或清洗现有 HTML；
- 不提供 DOM、模板文件编译、CSS 清洗、脚本执行、CSP 生成或浏览器运行时；
- URL 策略只检查字符和协议，不判断主机、重定向、同源或业务授权；
- `流式渲染`是同步回调接口，不提供异步背压、取消或事务式回滚；
- `原始`与`扩展`只适合源码常量或已经过专用安全处理的可信输出。

## 文档

- [使用指南](docs/GUIDE.md)
- [API 参考](docs/API.md)
- [架构](docs/ARCHITECTURE.md)
- [迁移指南](docs/MIGRATION.md)
- [性能与基准](docs/PERFORMANCE.md)
- [安全模型](docs/SECURITY_MODEL.md)
- [1.0.0 发布说明](docs/RELEASE_NOTES_1.0.0.md)
- [贡献指南](CONTRIBUTING.md)

可运行示例位于 `examples/`，7 份行为规格位于 `tests/`，可校验负载位于 `benchmarks/`。

本项目采用 [MIT 许可证](LICENSE)。
