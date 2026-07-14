# yanxu-html

`yanxu-html` 是言序的默认安全 HTML 节点与组件库。普通文字和属性值自动转义；原始 HTML 必须通过 `HTML原始内容` 或名称明确的 `原始` 工厂创建。

## 安全约定

- 属性名和标签名采用保守 ASCII 白名单，空白、引号、控制字符和逃逸符号无法进入输出。
- `href`、`src`、`action`、`formaction`、`poster`、`xlink:href` 默认只接受相对地址、片段、`http`、`https`、`mailto`、`tel`。
- `javascript:`、`data:`、未知协议及含空白/控制字符的 URL 默认拒绝。
- 空元素不能含子节点。

## 使用

```yanxu
引「包:yanxu-html」为 HTML；

定 页面 为 HTML.文档（
    HTML.元素（「main」，【HTML.属性（「class」，「page」）】，【
        HTML.元素（「h1」，【】，【HTML.文字（「言序 Web」）】），
        HTML.元素（「a」，【HTML.属性（「href」，「/docs」）】，【HTML.文字（「文档」）】）
    】）
）；

言 页面.渲染（）；
```

本地验收（从总工作区根目录执行）：

```sh
yanxu-language-new/target/debug/yanxu 查 yanxu-html/src/言序HTML.yx
yanxu-language-new/target/debug/yanxu 试 yanxu-html/tests --json
```

当前版本是 `0.1.0`，按 MIT License 发布。
