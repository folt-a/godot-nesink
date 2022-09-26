日本語

<br />

[![MIT License](https://img.shields.io/badge/License-MIT-25B3A0?style=flat-square)](https://github.com/ydipeepo/godot-motion/blob/main/LICENSE.md)
[![@ydipeepo](https://img.shields.io/badge/@ydipeepo-1DA1F2?style=flat-square&logo=twitter&logoColor=white)](https://twitter.com/ydipeepo)

<br />

![Nesinkrona](https://raw.githubusercontent.com/ydipeepo/godot-nesink/main/header.png)

<br />

# Nesinkrona (β)

まだ確定していない結果を単一の型で扱うことによりコードの取り回しをよくします。[Async Helper](https://github.com/ydipeepo/godot-async-helper) (Godot 3) の Godot 4 移植版。

* 実装が単純なので高速です
* シグナルやコルーチンが入り組むコードを自然に書けるようになります
* yield によるイテレーションを再現するパターンを含みます

<br />

#### 何のために作ったか

(AsyncHelper でも似たような問題に対処していましたが、このアドオンはもう少しパターン化して) 非同期的な処理を書いていると出くわす困った状況の解決を安全に手助けします。

<br />

##### 例えば...

例えば 3.5 での yield による待機:

```GDScript
#
# シグナル a もしくはシグナル b, もしくは一定時間が経過したらシグナル f を発火させたい
#

signal a
signal b
signal f

var _counter = 0

func _wait_a():
	yield(self, "a")
	_counter += 1
	if _counter == 1: emit_signal("f")

func _wait_b():
	yield(self, "b")
	_counter += 1
	if _counter == 1: emit_signal("f")

func _wait_timeout():
	yield(get_tree().create_timer(3.0), "timeout")
	_counter += 1
	if _counter == 1: emit_signal("f")

func _begin_wait():
	_counter = 0
	_wait_a()       # 並列的に動かしたいため yield しない
	_wait_b()       # 同上
	_wait_timeout() # 同上
```

GDScript 2.0 (少なくとも beta1) では、これが await になりました。以下のような書き方ができて一見ちょっと便利です:

```GDScript
signal a
signal b
signal f

func _begin_wait():
	var state = { "counter": 0 } # コピーキャプチャされるため辞書に入れた
	var wait_a = func():
		await a
		state.counter += 1
		if state.counter == 1: f.emit()
	func wait_b = func():
		await b
		state.counter += 1
		if state.counter == 1: f.emit()
	func wait_timeout = func():
		await get_tree().create_timer(3.0).timeout
		state.counter += 1
		if state.counter == 1: f.emit()
	wait_a.call()
	wait_b.call()
	wait_timeout.call()
```

yield から await に変わって、インライン関数も加わって、機能モリモリで書きやすさは向上しましたが何か問題は残ったままな感じです。このアドオンでその匂いを消臭します:

```GDScript
signal a
signal b
signal f

func _begin_wait():
	await Async.wait_any([
		Async.from_signal(a),
		Async.from_signal(b),
		Async,delay(3.0)])
	f.emit()
```

短くなりました。

<br />

##### 他にも...

例えばフェードインさせもしその途中にマウス左ボタンが押されたらスキップさせるとします:

```GDScript
func _ready():
	$ColorRect.color.a = 0.0
	var state = { "counter": 0 }
	var tween = create_tween()
	var wait_trailer = func():
		tween.stop()
		$ColorRect.color.a = 1.0
	var wait_tween = func():
		tween.tween_property($ColorRect, "color:a", 1.0, 3.0)
		await tween.finished # *1
		state.counter += 1
		if state.counter == 1: wait_trailer.call()
	var wait_input = func():
		while state.counter == 0:
			var event = (await gui_input) as InputEventMouseButton
			if event and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed:
				state.counter += 1
				if state.counter == 1: wait_trailer.call()
				break
	wait_tween.call()
	wait_input.call()
```

上下に処理が行ったり来たりしてしまって読みにくいです。なので Async を使って以下のようにします:

```GDScript
func _ready():
	$ColorRect.color.a = 0.0
	var tween = create_tween()
	tween.tween_property($ColorRect, "color:a", 1.0, 3.0)
	await Async.wait_any([
		Async.from_signal(tween.finished),
		Async.from(func():
			while true:
				var event = (await gui_input) as InputEventMouseButton
				if event and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed:
					break)
	])
	tween.stop()
	$Color.color.a = 1.0
```

プログラムの流れが一方向になり少し短くなりました。もう少しわかりやすいように何度も使うような処理はヘルパーを作ってしまうと楽です:

```GDScript
func Async_from_mouse_button(button_index: int) -> Async:
	var state := { "async": null }
	state.async = Async.from(func():
		while state.async == null or state.async.is_pending:
			var event = (await gui_input) as InputEventMouseButton
			if event and event.button_index == button_index and event.is_pressed:
				break)
	return state.async
```

こういうのを準備しておけばもう少し短くなります:

```GDScript
func _ready():
	var tween = create_tween()
	tween.tween_property($ColorRect, "color:a", 1.0, 3.0)
	await Async.wait_any([
		Async.from_signal(tween.finished),
		Async_from_mouse_button(MOUSE_BUTTON_LEFT),
	])
	tween.stop()
	$Color.color.a = 1.0
```

<br />

#### AsyncHelper からの変更点

Godot 3.5 GDScript の制約上妥協していた箇所の設計を変え (グッジョブ 4.0)、さらに単位が結果を返せるようになりました。またいくつかの機能が加わっています。

<br />

##### 変更箇所

* Task を Async に変更
* TaskUnit を Async に変更
* Task.when_all() を Async.all() に変更
* Task.when_any() を Async.any() に変更

* CancellationTokenSource と CancellationToken を Cancel に変更 (1 つにまとめた)
* Task.from_signal() を Async.from_signal_name() に変更

<br />

##### 新しく追加された機能

* Async.all_settled() を追加 (Async.all() はすべての完了を待つが、Async.all_settled() は完了を問わず処理を終えたことを待つ)
* Async.race() を追加 (Async.any() はどれか 1 つの完了を待つが、Async.race() は完了を問わず処理を終えたことを待つ)
* インライン関数 (ラムダ式、正式な名前不明) から生成メソッドを追加
  * Async.from()
  * Async.from_callback()

* また、継続メソッドを追加
  * async.then()
  * async.then_callback()
* Signal オブジェクトに対応した生成メソッドを追加
  * Async.from_signal()
* キャンセルのタイミングを ?sync.*_callback() メソッドを除き async.wait() に集約した
* ネストされた Async をアンラップするメソッドを追加
  * async.unwrap()
* AsyncIterator を追加
  * yield & GDScriptFunctionState.resume() でやっていたイテレータ的なものを Async で再現したもの
* AsyncGenerator を追加
  * AsyncIterator を双方向にしたもので、生成側からコルーチンへも値を渡せる

<br />

JS の Promise や Iterator, Generator に近くなってます。

<br />

---

<br />

<br />

## 準備

まだ beta1 に合わせて書き直した段階ですので、Godot AssetLib では配信していませんし申請もしていません。

<br />

#### デモを確認したい

1. このリポジトリをクローンして Godot Engine で開きます
2. (`demos/Demo.tscn` をメインシーンに設定して、) F5

#### アドオンを導入したい

1. `addons/godot-nesink` ディレクトリを丸ごとプロジェクトに複製します
2. `Nesinkrona` アドオンを有効にします
3. 書く。

<br />

## リファレンス

[Wiki](https://github.com/ydipeepo/godot-nesink/wiki) に移しました。

<br />

---

<br />

## バグの報告や要望など

バグの修正や報告、ドキュメント翻訳、およびその他の改善など歓迎いたします。
