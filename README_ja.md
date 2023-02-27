**[WIP] This repo does not work with the latest Godot4 RC.**

---

This original repository is [https://github.com/ydipeepo/godot-nesink](https://github.com/ydipeepo/godot-nesink) **(Archived)**

[English](https://github.com/folt-a/godot-nesink/blob/main/README.md) | 日本語 | [简体中文](https://github.com/folt-a/godot-nesink/blob/main/README_zh.md)

<br />

[![MIT License](https://img.shields.io/badge/License-MIT-25B3A0?style=flat-square)](https://github.com/folt-a/godot-motion/blob/main/LICENSE.md)

<br />

```GDScript
# 複数の Async もしくは Signal, コルーチンを新たな Async としてまとめることができます
var all_async := Async.all([
    Async.from(_coro), # Async から
    obj.signal,        # Signal から
    func(): return 0   # Coroutine から
])
var result = await all_async.wait()

# もしくは、即時待機することもできます
var result = await Async.wait_all([
    Async.from(_coro), # from Async
    obj.signal, # from Signal
    func():
        # from Coroutine
        pass
])

# await のための一般的なメソッドをすべて含みます
Async.all()
Async.all_settled()
Async.any()
Async.race()
Async.wait_all()
Async.wait_all_settled()
Async.wait_any()
Async.wait_race()

# 継続やキャンセルもサポートします
var another_async = async.then(func(prev_result):
    return prev_result * prev_result)
var cancel := Cancel.new()
await another_async.wait(cancel)
```

<br />

# Nesinkrona (for Godot 4)

Godot 4 の await 足回りを強化するアドオン。[Async Helper](https://github.com/ydipeepo/godot-async-helper) (Godot 3) の Godot 4 移植版です。

<br />

* シグナルやコルーチンが入り組むコードの見通しを良くし、自然に書けるようにします (JS の Promise や C# の Task に近いです)
* 実装が単純なので高速です
* await 外からキャンセルすることができます (外部から中断させることができる)
* yield によるイテレーションを再現するパターンを含みます (実験的)

<br />

---

<br />

## 準備

<br />

#### デモを確認したい

1. このリポジトリをクローンして Godot Engine で開きます
2. (`demos/Demo.tscn` をメインシーンに設定して、) F5

#### アドオンを導入したい

1. `addons/godot-nesink` ディレクトリを丸ごとプロジェクトに複製します
2. `Nesinkrona` アドオンを有効にします
3. 書く。

<br />

Async クラス詳細はこちら: [📖 Wiki](https://github.com/folt-a/godot-nesink/wiki/Async)

<br />

---

<br />

## バグの報告や要望など

バグの修正や報告、ドキュメント翻訳、およびその他の改善など歓迎いたします。
