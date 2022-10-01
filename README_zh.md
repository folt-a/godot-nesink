[English](https://github.com/ydipeepo/godot-nesink/blob/main/README.md) | [日本語](https://github.com/ydipeepo/godot-nesink/blob/main/README_ja.md) | 简体中文

<br />

[![MIT License](https://img.shields.io/badge/License-MIT-25B3A0?style=flat-square)](https://github.com/ydipeepo/godot-motion/blob/main/LICENSE.md)
[![@ydipeepo](https://img.shields.io/badge/@ydipeepo-1DA1F2?style=flat-square&logo=twitter&logoColor=white)](https://twitter.com/ydipeepo)

<br />

```GDScript
# 多个 Async 或信号 (Signal) 或 Coroutine 会组合成一个新的 Async
var all_async := Async.all([
    Async.from(_coro), # from Async
    obj.signal,        # from Signal
    func(): return 0   # from Coroutine
])
var result = await all_async.wait()

# 或者可以立即 await 它
var result = await Async.wait_all([
    Async.from(_coro),
    obj.signal,
    func(): return 0
])

# 包括等待的大部分一般模式
Async.all()
Async.all_settled()
Async.any()
Async.race()
Async.wait_all()
Async.wait_all_settled()
Async.wait_any()
Async.wait_race()

# 支持 Async 的延续和取消
var another_async = async.then(func(prev_result):
    return prev_result * prev_result)
var cancel := Cancel.new()
await another_async.wait(cancel)
```

<br />

# Nesinkrona (for Godot 4 β1, 2)

一个增强 GDScript 2.0 await 的插件。

<br />

* 它提高了与信号和程序交织在一起的代码的可见度和自然度。(类似于 JS 的 Promise 或 C# 的 Task)
* 由于代码简单，所以速度快。
* 可以从外部取消 await。
* 包含 yield 重现迭代的类型。(实验的)

<br />

---

<br />

## 如何使用

<br />

#### 检查演示项目

1. Git Clone 然后在 Godot 引擎中打开。
2. (选择 `demo/Demo.tscn` 作为主场景然后) F5



#### 安装这插件

1. Git clone 然后将 `addons/godot-nesink` 复制到您的项目中。
2. 启用 `Nesinkrona` 插件。
3. 写写代码。

<br />

还有细节: [📖 维基 (Google Translated)](https://github-com.translate.goog/ydipeepo/godot-nesink/wiki/Async?_x_tr_sl=auto&_x_tr_tl=zh-cn)

<br />

---

<br />

## 贡献

我们非常欢迎提供 bug 的修复、文档翻译，和任何其他改进! 谢谢!
