English | [日本語](https://github.com/folt-a/godot-nesink/blob/main/README_ja.md) | [简体中文](https://github.com/folt-a/godot-nesink/blob/main/README_zh.md)

<br />

[![MIT License](https://img.shields.io/badge/License-MIT-25B3A0?style=flat-square)](https://github.com/folt-a/godot-nesink/blob/main/LICENSE.md)

<br />

# Nesinkrona (for Godot 4)

An addon to enhance the awaitability of GDScript 2.0.

<br />

* It improves the readability and naturalness of code that is intermingled with signals and coroutines. (similar to Promise in JS or Task in C#).
* Fast due to simple implementation.
* Can be canceled from outside of await.
* Contains patterns that reproduce iterations with yield. (experimental)

<br />

---

```GDScript
# Multiple Async or Signal or Coroutine can be combined into a new Async
var all_async := Async.all([
    Async.from(_coro), # from Async
    obj.signal,        # from Signal
    func(): return 0   # from Coroutine
])
var result = await all_async.wait()

# or you can await it immediately.
var result = await Async.wait_all([
    Async.from(_coro),
    obj.signal,
    func(): return 0
])

# Includes general patterns for await
Async.all()
Async.all_settled()
Async.any()
Async.race()
Async.wait_all()
Async.wait_all_settled()
Async.wait_any()
Async.wait_race()

# and support continuations and cancellations.
var another_async = async.then(func(prev_result):
    return prev_result * prev_result)
var cancel := Cancel.new()
await another_async.wait(cancel)
```

<br />

## How do I use it?

<br />

#### Checking demos

1. Git clone then open in Godot Engine.
2. (Select `demo/Demo.tscn` as Main Scene then) F5!



#### Add-on installation

1. Git clone then copy `addons/godot-nesink` to your project.
2. Activate `Nesinkrona` addon.
3. Code!

<br />

And details: [📖 Wiki (Google Translated)](https://github-com.translate.goog/folt-a/godot-nesink/wiki/Async?_x_tr_sl=auto&_x_tr_tl=en)

<br />

---

<br />

## Contributing

We are grateful to the community for contributing bug fixes, documentation, translations, and any other improvements!



## Original repository

This repository was transfer from [ydipeepo](https://github.com/ydipeepo)

ありがとうございます……!