## 非同期的な処理の完了とその結果、もしくはキャンセルされたという状態を表すインターフェイスです。
##
## 非同期的な処理を抽象化し、将来決まる結果をこの共通のインターフェイスからアクセスできるようにします。
## 完了もしくはキャンセルされたという状態と、完了した場合はその結果を保持し [method wait] ([method NesinkronaAwaitable.wait]) メソッドから取得することができます。
## またいくつかの重要なファクトリメソッドを公開します。
class_name Async extends NesinkronaAwaitable

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

## 完了した状態の [Async] を作成します。[br]
## [br]
## [b]使い方[/b]
##     [codeblock]
##     var async := Async.completed("result")
##     assert(async.is_completed)
##     assert(await async.wait() == "result")
##     [/codeblock]
static func completed(result = null) -> Async:
	return NesinkronaCanon.create_completed(result)

## キャンセルされた状態の [Async] を作成します。[br]
## [br]
## [b]使い方[/b]
##     [codeblock]
##     var async := Async.canceled()
##     assert(async.is_canceled)
##     assert(await async.wait() == null)
##     [/codeblock]
static func canceled() -> Async:
	return NesinkronaCanon.create_canceled()

## コルーチン (もしくは関数) の戻り値を結果として完了する [Async] を作成します。[br]
## [br]
## [b]使い方[/b]
##     [codeblock]
##     var async1 := Async.from(func ():
##         await get_tree().create_timer(1.0).timeout
##     )
##     var async2 := Async.from(func ():
##         await get_tree().create_timer(1.0).timeout
##         return 123
##     )
##     print(await async1.wait()) # <null>
##     print(await async2.wait()) # 123
##     [/codeblock]
static func from(coroutine: Callable) -> Async:
	assert(coroutine != null)
	return NesinkronaFromAsync.new(coroutine)

## シグナルを受信するとその引数配列を結果として完了する [Async] を作成します。[br]
## [br]
## [b]補足[/b][br]
## 作成後、一度だけシグナルを受信します。受信すると完了しその結果は不変です。[br]
## もしシグナルが引数を持つ場合、その個数を [code]signal_argc[/code] に指定する必要があります。[br]
## 間違った個数を指定すると正しく受信できません。[br]
## [br]
## [b]使い方[/b]
##     [codeblock]
##     signal my_event_0
##     signal my_event_1(a)
##     signal my_event_2(a, b)
##
##     var async0 := Async.from_signal(my_event_0)
##     var async1 := Async.from_signal(my_event_1, 1) # シグナルの引数の個数を指定する必要があります
##     var async2 := Async.from_signal(my_event_2, 2) # 同上
##     print(await async0.wait()) # []
##     print(await async1.wait()) # [1]
##     print(await async2.wait()) # [1, 2]
##
##     my_event_0.emit()     # どこかにこのようなエミッションがあるとします
##     my_event_1.emit(1)    # 同上
##     my_event_2.emit(1, 2) # 同上
##     [/codeblock]
static func from_signal(
	signal_: Signal,
	signal_argc := 0) -> Async:

	assert(not signal_.is_null())
	assert(0 <= signal_argc and signal_argc <= NesinkronaFromSignalAsync.MAX_SIGNAL_ARGC)
	return NesinkronaFromSignalAsync.new(signal_, signal_argc)

## 文字列によりシグナル名を指定し、そのシグナルを受信すると引数配列を結果として完了する [Async] を作成します。[br]
## [br]
## [b]補足[/b][br]
## シグナルの指定方法が異なるだけで、他は [method from_signal] メソッドと同じ注意を払う必要があります。
static func from_signal_name(
	object: Object,
	signal_name: StringName,
	signal_argc := 0) -> Async:

	assert(object != null and not object.is_queued_for_deletion())
	assert(0 <= signal_argc and signal_argc <= NesinkronaFromSignalNameAsync.MAX_SIGNAL_ARGC)
	return NesinkronaFromSignalNameAsync.new(
		object,
		signal_name,
		signal_argc)

## タイムアウトすると完了する [Async] を作成します。[br]
## [br]
## 結果は [code]timeout[/code] で指定した値となります。[br]
## [br]
## [b]補足[/b][br]
## 第 1 引数 [code]timeout[/code] は 0.0 以上である必要があります。
## 過去は指定できません。[br]
## [br]
## [b]使い方[/b]
##     [codeblock]
##     var async := Async.delay(1.0)
##     print(await async.wait()) # 1.0
##     [/codeblock]
static func delay(timeout: float) -> Async:
	assert(NesinkronaDelayAsync.MIN_TIMEOUT <= timeout)
	
	return \
		NesinkronaCompletedAsync.new(0.0) \
		if timeout == 0.0 else \
		NesinkronaDelayAsync.new(timeout)

## タイムアウト (ミリ秒) すると完了する [Async] を返します。[br]
## [br]
## [b]補足[/b][br]
## タイムアウトの単位が異なるだけで、他は [method delay] メソッドと同じ注意を払う必要があります。
static func delay_msec(timeout: float) -> Async:
	return delay(timeout / 1_000.0)

## タイムアウト (マイクロ秒) すると完了する [Async] を返します。[br]
## [br]
## [b]補足[/b][br]
## タイムアウトの単位が異なるだけで、他は [method delay] メソッドと同じ注意を払う必要があります。
static func delay_usec(timeout: float) -> Async:
	return delay(timeout / 1_000_000.0)

## すべての入力が完了すると、それぞれの結果を配列に格納したものを結果として完了する [Async] を作成します。[br]
## [br]
## 第 1 引数 [code]drains[/code] 配列には [Async] や [AsyncSequence] 以外の値も含めることができます。
## この引数に [Async] や [AsyncSequence] が含まれておりどれか 1 つでもキャンセルされると、
## このメソッドで作成した [Async] は完了ではなくキャンセルされた状態となります。[br]
## [br]
## [b]補足[/b][br]
## [u]すべての入力が完了した[/u]、という条件が必要な場合に使用します。
## もし完了やキャンセルを問わず待機が終わったことだけを待つ必要がある場合、
## 代わりに [method all_settled] メソッドを使います。[br]
## [br]
## [b]使い方[/b]
##     [codeblock]
##     var async := Async.all([
##         Async.completed(1234),
##         Async.delay(1.5),
##         Async.delay(2.0),
##         true,
##         "aaa",
##     )
##     print(await async.wait()) # [1234, 1.5, 2.0, true, "aaa"]
##     [/codeblock]
static func all(
	drains: Array,
	cancel: Cancel = null) -> Async:

	return \
		NesinkronaCanceledAsync.new() \
		if cancel and cancel.is_requested else \
		NesinkronaCompletedAsync.new([]) \
		if drains == null or 0 == len(drains) else \
		NesinkronaAllAsync.new(drains, cancel)

## すべての入力が完了もしくはキャンセルされると、それぞれの結果を [Async] のまま配列に格納したものを結果として完了する [Async] を作成します。[br]
## [br]
## 第 1 引数 [code]drains[/code] 配列には [Async] や [AsyncSequence] 以外の値も含めることができます。
## この引数に [Async] や [AsyncSequence] ではない値が含まれていると、
## それは完了した状態の [Async] に変換され処理されます。[br]
## [br]
## [b]補足[/b][br]
## [u]すべての入力がそれぞれ完了もしくはキャンセルされた[/u]、
## という条件が必要な場合に使用します。[br]
## [br]
## [b]使い方[/b]
##     [codeblock]
##     var async := Async.all_settled([
##         Async.delay(1.0),
##         Async.delay(2.0),
##         10,
##         20,
##     ])
##     var async_result: Array[Async] = await async.wait()
##     print(await async_result[0].wait()) # 1.0
##     print(await async_result[1].wait()) # 2.0
##     print(await async_result[2].wait()) # 10
##     print(await async_result[3].wait()) # 20
##     [/codeblock]
static func all_settled(
	drains: Array,
	cancel: Cancel = null) -> Async:

	return \
		NesinkronaCanon.create_completed([]) \
		if drains == null or 0 == len(drains) else \
		NesinkronaAllSettledAsync.new(drains, cancel)

## すべての入力のうち最初に完了した結果を、それを結果として完了する [Async] を作成します。[br]
## [br]
## 第 1 引数 [code]drains[/code] 配列には [Async] や [AsyncSequence] 以外の値も含めることができます。
## この引数に [Async] や [AsyncSequence] が含まれておりすべてがキャンセルされると、
## このメソッドで作成した [Async] は完了ではなくキャンセルされた状態となります。[br]
## [br]
# [b]補足[/b][br]
## [u]どれか 1 つでも完了した[/u]、という条件が必要な場合に使用します。
## もし完了やキャンセルを問わずどれか 1 つでも完了もしくはキャンセルされたことを待つ必要がある場合、
## 代わりに [method race] メソッドを使います。[br]
## [br]
## [b]使い方[/b]
##     [codeblock]
##     var async := Async.any([
##         Async.delay(1.0),
##         Async.delay(2.0),
##         Async.delay(3.0),
##     ])
##     print(await async.wait()) # 1.0
##     [/codeblock]
static func any(
	drains: Array,
	cancel: Cancel = null) -> Async:

	return \
		NesinkronaCanon.create_canceled() \
		if cancel and cancel.is_requested or drains == null or 0 == len(drains) else \
		NesinkronaAnyAsync.new(drains, cancel)

## すべての入力のうち最初に完了もしくはキャンセルされた結果を、それを [Async] のまま結果として完了する [Async] を作成します。[br]
## [br]
## 第 1 引数 [code]drains[/code] 配列には [Async] や [AsyncSequence] 以外の値も含めることができます。
## この引数に [Async] や [AsyncSequence] ではない値が含まれていると、
## それは完了した状態の [Async] に変換され処理されます。[br]
## [br]
## [b]補足[/b][br]
## [u]どれか 1 つでも完了もしくはキャンセルされた[/u]、
## という条件が必要な場合に使用します。[br]
## 第 1 引数 [code]drains[/code] は、1 以上の長さでなくてはなりません。[br]
## [br]
## [b]使い方[/b]
##     [codeblock]
##     var async := Async.race([
##         Async.canceled(),
##         Async.delay(2.0),
##         Async.delay(3.0),
##     ])
##     async = await async.wait()
##     print(async.is_canceled) # true
##     [/codeblock]
static func race(
	drains: Array,
	cancel: Cancel = null) -> Async:

	assert(drains != null and 0 < len(drains))
	return NesinkronaRaceAsync.new(drains, cancel)

## [method delay] で作成した [Async] に対して [method wait] を呼び出す短縮表記です。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## delay(timeout).wait(cancel)
## [/codeblock]
static func wait_delay(
	timeout: float,
	cancel: Cancel = null):

	return await delay(timeout).wait(cancel)

## [method delay_msec] で作成した [Async] に対して [method wait] を呼び出す短縮表記です。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## delay_msec(timeout).wait(cancel)
## [/codeblock]
static func wait_delay_msec(
	timeout: float,
	cancel: Cancel = null):

	return await delay_msec(timeout).wait(cancel)

## [method delay_usec] で作成した [Async] に対して [method wait] を呼び出す短縮表記です。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## delay_usec(timeout).wait(cancel)
## [/codeblock]
static func wait_delay_usec(
	timeout: float,
	cancel: Cancel = null):

	return await delay_usec(timeout).wait(cancel)

## [method all] で作成した [Async] に対して [method wait] を呼び出す短縮表記です。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## all(drains, cancel).wait(cancel)
## [/codeblock]
static func wait_all(
	drains: Array,
	cancel: Cancel = null):

	return await all(drains, cancel).wait(cancel)

## [method all_settled] で作成した [Async] に対して [method wait] を呼び出す短縮表記です。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## all_settled(drains, cancel).wait(cancel)
## [/codeblock]
static func wait_all_settled(
	drains: Array,
	cancel: Cancel = null):

	return await all_settled(drains, cancel).wait(cancel)

## [method any] で作成した [Async] に対して [method wait] を呼び出す短縮表記です。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## any(drains, cancel).wait(cancel)
## [/codeblock]
static func wait_any(
	drains: Array,
	cancel: Cancel = null):

	return await any(drains, cancel).wait(cancel)

## [method race] で作成した [Async] に対して [method wait] を呼び出す短縮表記です。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## race(drains, cancel).wait(cancel)
## [/codeblock]
static func wait_race(
	drains: Array,
	cancel: Cancel = null):

	return await race(drains, cancel).wait(cancel)

## 継続するコルーチン (もしくは関数) を接続した新たな [Async] を作成します。[br]
## [br]
## 前の結果を写像する場合 ([method Array.map] 的な使い方) や、
## 結果から別のコルーチンへ処理を渡す場合に使います。[br]
## [br]
## [b]補足[/b][br]
## 第 1 引数 [code]coroutine[/code] は引数を 1 つ受け取る [Callable] でなくてはなりません。[br]
## [br]
## [b]使い方[/b]
##     [codeblock]
##     var async := Async.completed(10).then(func (result): return result * result)
##     print(await async.wait()) # 100
##     [/codeblock]
func then(
	coroutine: Callable,
	cancel: Cancel = null) -> Async:

	assert(coroutine != null)
	return NesinkronaThenAsync.new(self, cancel, coroutine)

## 結果が [Async] である場合、指定した回数アンラップを試みた新たな [Async] を作成します。[br]
## [br]
## [b]使い方[/b]
##     [codeblock]
##     var async := Async.completed(Async.completed(10)) # Async に Async がネストされています
##     print(await async.unwrap().wait()) # 10
##     [/codeblock]
func unwrap(
	depth := 1,
	cancel: Cancel = null) -> Async:

	assert(0 <= depth)
	return \
		NesinkronaCanon.create_canceled() \
		if cancel and cancel.is_requested or is_canceled else \
		self \
		if depth == 0 else \
		NesinkronaUnwrapAsync.new(self, cancel, depth)

## ジェネレータ関数 (yield 関数を引数に取るコルーチン) から [AsyncSequence] を作成します。[br]
## [br]
## [b]使い方[/b]
##     [codeblock]
##     var seq := Async.sequence(func (yield_):
##         print(await yield_.call("aaa")) # 0
##         print(await yield_.call("bbb")) # 1
##         return "end")
##
##     var i := 0
##     while not seq.is_completed:
##         print(await seq.next(i)) # "aaa"
##                                  # "bbb"
##     print(await seq.wait())      # "end"
##     [/codeblock]
static func sequence(generator: Callable) -> AsyncSequence:
	assert(generator != null)
	return AsyncSequence.from(generator)

