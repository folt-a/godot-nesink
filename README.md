日本語

<br />

[![MIT License](https://img.shields.io/badge/License-MIT-25B3A0?style=flat-square)](https://github.com/ydipeepo/godot-motion/blob/main/LICENSE.md)
[![@ydipeepo](https://img.shields.io/badge/@ydipeepo-1DA1F2?style=flat-square&logo=twitter&logoColor=white)](https://twitter.com/ydipeepo)

<br />

```GDScript
# 複数の Async もしくは Signal, コルーチンを新たな Async としてまとめることができます
var all_async := Async.all([
    Async.from(_coro), # from Async
    obj.signal, # from Signal
    func():
        # from Coroutine
        pass
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

# いくつかの await しやすくするためのメソッドがあります
Async.all()
Async.all_settled()
Async.any()
Async.race()
Async.wait_all()
Async.wait_all_settled()
Async.wait_any()
Async.wait_race()

# そして継続やキャンセルをサポートします
var another_async = async.then(func(prev_result):
    return prev_result * prev_result)
var cancel := Cancel.new()
await another_async.wait(cancel)
```

<br />

# Nesinkrona (β)

Godot 4 の await 足回りを強化するアドオン。[Async Helper](https://github.com/ydipeepo/godot-async-helper) (Godot 3) の Godot 4 移植版です。

<br />

* シグナルやコルーチンが入り組むコードの見通しを良くし、自然に書けるようにします
* 実装が単純なので高速です
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

## どうやって使うの？

[📖 Wiki](https://github.com/ydipeepo/godot-nesink/wiki) に移しました。

<br />

---

<br />

## バグの報告や要望など

バグの修正や報告、ドキュメント翻訳、およびその他の改善など歓迎いたします。
