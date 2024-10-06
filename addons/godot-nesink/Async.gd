## 非同期的な処理の完了とその結果、もしくはキャンセルされたという状態を表すインターフェイスです。
##
## 非同期的な処理を抽象化し、将来決まる結果をこの共通のインターフェイスからアクセスできるようにします。
## 完了もしくはキャンセルされたという状態と、完了した場合はその結果を保持し [method wait] メソッドから取得することができます。
## またいくつかの重要なファクトリメソッドを公開します。
class_name Async

#-------------------------------------------------------------------------------
# 定数
#-------------------------------------------------------------------------------

enum {
	## [b](アドオン内もしくは実装内でのみ使用)[/b]
	## まだ完了もしくはキャンセルされておらず待機中であることを表します。
	STATE_PENDING,
	## [b](アドオン内もしくは実装内でのみ使用)[/b]
	## まだ完了もしくはキャンセルされておらず待機中であり、
	## 1 度以上 [method wait] メソッドにより待機している箇所があることを表します。
	STATE_PENDING_WITH_WAITERS,
	## [b](アドオン内もしくは実装内でのみ使用)[/b]
	## 完了したことを表します。
	STATE_COMPLETED,
	## [b](アドオン内もしくは実装内でのみ使用)[/b]
	## キャンセルされたことを表します。
	STATE_CANCELED,
}

enum {
	## アイドル時に処理されるよう遅延されることを表します。
	DEFER_IDLE,
	## _process フレームに処理されるよう遅延されることを表します。
	DEFER_PROCESS_FRAME,
	## _physics_process フレームに処理されるよう遅延されることを表します。
	DEFER_PHYSICS_FRAME,
}

## 条件一致を省略するためのプレースホルダ。
static var SKIP := Object.new()

#-------------------------------------------------------------------------------
# プロパティ
#-------------------------------------------------------------------------------

## この待機可能な単位が完了している場合 true を返します。[br]
## [br]
## [b]補足[/b][br]
## [method wait] を待機した後は、[member is_canceled] もしくは
## このプロパティのうちどちらかが必ず true になります。
var is_completed: bool:
	get:
		return get_state() == STATE_COMPLETED

## この待機可能な単位がキャンセルされている場合 true を返します。[br]
## [br]
## [b]補足[/b][br]
## [method wait] を待機した後は、[member is_completed] もしくは
## このプロパティのうちどちらかが必ず true になります。
var is_canceled: bool:
	get:
		return get_state() == STATE_CANCELED

## この待機可能な単位がまだ完了もしくはキャンセルされていない場合 true を返します。
var is_pending: bool:
	get:
		var state := get_state()
		return \
			state == STATE_PENDING or \
			state == STATE_PENDING_WITH_WAITERS

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

## 完了した状態の [Async] を作成します。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var async := Async.completed("result")
## assert(async.is_completed)
## assert(await async.wait() == "result")
## [/codeblock]
static func completed(result: Variant = null) -> Async:
	return NesinkronaCompletedAsync.new(result)

## キャンセルされた状態の [Async] を作成します。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var async := Async.canceled()
## assert(async.is_canceled)
## assert(await async.wait() == null)
## [/codeblock]
static func canceled() -> Async:
	return NesinkronaCanceledAsync.new()

## コルーチン (もしくは関数) の戻り値を結果として完了する [Async] を作成します。[br]
## [br]
## [b]補足[/b][br]
## 第 1 引数 [code]coroutine[/code] は引数を受け取りません。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var async1 := Async.from(func():
##     await get_tree().create_timer(1.0).timeout)
## var async2 := Async.from(func():
##     await get_tree().create_timer(1.0).timeout
##     return 123)
## print(await async1.wait()) # <null>
## print(await async2.wait()) # 123
## [/codeblock]
static func from(coroutine: Callable) -> Async:
	return NesinkronaFromAsync.new(coroutine)

## コルーチン (もしくは関数) を呼び出し結果を待機する新たな [Async] を作成します。[br]
## [br]
## [b]補足[/b][br]
## 第 1 引数 [code]coroutine[/code] は引数を 2 つ受け取る
## [Callable] でなくてはなりません。この引数には完了コールバック、
## キャンセルコールバックが渡されます。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var async1 := Async.from(func(complete: Callback, cancel: Callback):
##     get_tree().create_timer(1.0).timeout.connect(complete))
## var async2 := Async.from(func():
##     get_tree().create_timer(1.0).timeout.connect(complete.bind(123)))
## print(await async1.wait()) # <null>
## print(await async2.wait()) # 123
## [/codeblock]
static func from_callback(coroutine: Callable, unbind_cancel := false) -> Async:
	return NesinkronaFromCallbackAsync.new(coroutine, unbind_cancel)

## シグナルを受信するとその引数を結果として完了する [Async] を作成します。[br]
## [br]
## シグナル引数は [Array] に格納され結果となります。[br]
## [br]
## [b]補足[/b][br]
## もしシグナルが引数を持つ場合、その個数を [code]signal_argc[/code] に指定する必要があります。[br]
## 間違った個数を指定すると正しく受信できません。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## signal my_event_0
## signal my_event_1(a)
## signal my_event_2(a, b)
##
## var async0 := Async.from_signal(my_event_0)
## var async1 := Async.from_signal(my_event_1, 1) # シグナルの引数の個数を指定する必要があります
## var async2 := Async.from_signal(my_event_2, 2) # 同上
## print(await async0.wait()) # []
## print(await async1.wait()) # [1]
## print(await async2.wait()) # [1, 2]
##
## my_event_0.emit()     # どこかにこのようなエミッションがあるとします
## my_event_1.emit(1)    # 同上
## my_event_2.emit(1, 2) # 同上
## [/codeblock]
static func from_signal(signal_: Signal, signal_argc := 0) -> Async:
	assert(not signal_.is_null())
	assert(
		signal_argc >= 0 and
		signal_argc <= NesinkronaFromSignalAsync.MAX_SIGNAL_ARGC)
	return NesinkronaFromSignalAsync.new(signal_, signal_argc)

## 文字列によりシグナル名を指定し、そのシグナルを受信すると引数を結果として完了する [Async] を作成します。[br]
## [br]
## [b]補足[/b][br]
## シグナルの指定方法が異なるだけで、他は [method from_signal] メソッドと同じ注意を払う必要があります。
static func from_signal_name(
	object: Object,
	signal_name: StringName,
	signal_argc := 0) -> Async:

	assert(
		object != null and
		not object.is_queued_for_deletion())
	assert(
		signal_argc >= 0 and
		signal_argc <= NesinkronaFromSignalNameAsync.MAX_SIGNAL_ARGC)
	return NesinkronaFromSignalNameAsync.new(object, signal_name, signal_argc)

## シグナル引数が一致した場合にのみ完了する条件付き [Async] を作成します。[br]
## [br]
## [method Async.wait] はシグナル引数を配列に格納したものを返します。
static func from_conditional_signal(
	signal_: Signal,
	signal_args := []) -> Async:

	assert(not signal_.is_null())
	assert(
		signal_args.size() <= NesinkronaFromConditionalSignalAsync.MAX_SIGNAL_ARGC)
	return NesinkronaFromConditionalSignalAsync.new(signal_, signal_args)

## シグナル引数が一致した場合にのみ完了する条件付き [Async] を作成します。[br]
## [br]
## [method Async.wait] はシグナル引数を配列に格納したものを返します。
static func from_conditional_signal_name(
	object: Object,
	signal_name: StringName,
	signal_args := []) -> Async:

	assert(object and not object.is_queued_for_deletion())
	assert(
		signal_args.size() <= NesinkronaFromConditionalSignalNameAsync.MAX_SIGNAL_ARGC)
	return NesinkronaFromConditionalSignalNameAsync.new(object, signal_name, signal_args)

## [param callsite] で指定したタイミングで完了する [Async] を作成します。
static func defer(callsite := DEFER_IDLE) -> Async:
	match callsite:
		DEFER_IDLE:
			return NesinkronaDeferIdleAsync.new()
		DEFER_PROCESS_FRAME:
			return NesinkronaDeferProcessFrameAsync.new()
		DEFER_PHYSICS_FRAME:
			return NesinkronaDeferPhysicsFrameAsync.new()
		_:
			assert(false)
			return null

## タイムアウトすると完了する [Async] を作成します。[br]
## [br]
## 結果は第 1 引数 [code]timeout[/code] と同じ値となります。[br]
## [br]
## [b]補足[/b][br]
## 第 1 引数 [code]timeout[/code] は 0.0 以上である必要があります。
## また過去は指定できません。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var async := Async.delay(1.0)
## print(await async.wait()) # 1.0
## [/codeblock]
static func delay(timeout: float) -> Async:
	assert(NesinkronaDelayAsync.MIN_TIMEOUT <= timeout)
	return \
		completed(0.0) \
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

## すべての入力が完了すると、それぞれの結果を配列に格納したものを結果として完了する新たな [Async] を作成します。[br]
## [br]
## 第 1 引数 [code]drains[/code] 配列には [Async] や [AsyncSequence] 以外の値も含めることができます。[br]
## [br]
## [b]補足[/b][br]
## 第 1 引数 [code]drains[/code] 配列に [Async] や [AsyncSequence] が含まれている場合、
## どれか 1 つでもキャンセルされるとこのメソッドで作成した [Async] はキャンセルされた状態となります。
## これは結果を作成できないためです。もし完了やキャンセルを問わず待機が終わったことだけを待つ場合、
## このメソッドではなく代わりに [method all_settled] メソッドを使います。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var async := Async.all([
##     Async.completed(1234),
##     Async.delay(1.5),
##     Async.delay(2.0),
##     true,
##     "aaa",
## )
## print(await async.wait()) # [1234, 1.5, 2.0, true, "aaa"]
## [/codeblock]
static func all(drains: Array, cancel: Cancel = null) -> Async:
	return \
		canceled() \
		if cancel and cancel.is_requested else \
		completed([]) \
		if drains.is_empty() else \
		NesinkronaAllAsync.new(drains, cancel)

## すべての入力が完了もしくはキャンセルされると、それぞれの結果を [Async] のまま配列に格納したものを結果として完了する [Async] を作成します。[br]
## [br]
## 第 1 引数 [code]drains[/code] 配列には [Async] や [AsyncSequence] 以外の値も含めることができます。[br]
## [br]
## [b]補足[/b][br]
## 第 1 引数 [code]drains[/code] 配列に [Async] や [AsyncSequence] ではない値が含まれていると、
## それは完了した状態の [Async] に変換され処理されます。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var async := Async.all_settled([
##     Async.delay(1.0),
##     Async.delay(2.0),
##     10,
##     20,
## ])
## var async_result: Array[Async] = await async.wait()
## print(await async_result[0].wait()) # 1.0
## print(await async_result[1].wait()) # 2.0
## print(await async_result[2].wait()) # 10
## print(await async_result[3].wait()) # 20
## [/codeblock]
static func all_settled(drains: Array, cancel: Cancel = null) -> Async:
	return \
		completed([]) \
		if drains.is_empty() else \
		NesinkronaAllSettledAsync.new(drains, cancel)

## すべての入力のうちどれか 1 つが完了すると、それを結果として完了する新たな [Async] を作成します。[br]
## [br]
## 第 1 引数 [code]drains[/code] 配列には [Async] や [AsyncSequence] 以外の値も含めることができます。
## [br]
# [b]補足[/b][br]
## もし完了やキャンセルを問わずど待機が終わったことだけを待つ場合、
## このメソッドではなく代わりに [method race] メソッドを使います。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var async := Async.any([
##     Async.canceled(),
##     Async.delay(2.0),
##     Async.delay(3.0),
## ])
## print(await async.wait()) # 2.0
## [/codeblock]
static func any(drains: Array, cancel: Cancel = null) -> Async:
	return \
		canceled() \
		if cancel != null and cancel.is_requested or drains.is_empty() else \
		NesinkronaAnyAsync.new(drains, cancel)

## すべての入力のうちどれか 1 つが完了もしくはキャンセルされると、それを結果として完了する新たな [Async] を作成します。[br]
## [br]
## 第 1 引数 [code]drains[/code] 配列には [Async] や [AsyncSequence] 以外の値も含めることができます。[br]
## [br]
## [b]補足[/b][br]
## 第 1 引数 [code]drains[/code] は、1 以上の長さでなくてはなりません。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var async := Async.race([
##     Async.canceled(),
##     Async.delay(2.0),
##     Async.delay(3.0),
## ])
## async = await async.wait()
## print(async.is_canceled) # true
## [/codeblock]
static func race(drains: Array, cancel: Cancel = null) -> Async:
	assert(not drains.is_empty())
	return NesinkronaRaceAsync.new(drains, cancel)

## [param callsite] で指定したタイミングを待機します。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## defer(callsite).wait(cancel)
## [/codeblock]
static func wait_defer(callsite := DEFER_IDLE, cancel: Cancel = null) -> Variant:
	return await defer(callsite).wait(cancel)

## [method delay] で作成した [Async] に対して [method wait] を呼び出す短縮表記です。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## delay(timeout).wait(cancel)
## [/codeblock]
static func wait_delay(timeout: float, cancel: Cancel = null) -> Variant:
	return await delay(timeout).wait(cancel)

## [method delay_msec] で作成した [Async] に対して [method wait] を呼び出す短縮表記です。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## delay_msec(timeout).wait(cancel)
## [/codeblock]
static func wait_delay_msec(timeout: float, cancel: Cancel = null) -> Variant:
	return await delay_msec(timeout).wait(cancel)

## [method delay_usec] で作成した [Async] に対して [method wait] を呼び出す短縮表記です。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## delay_usec(timeout).wait(cancel)
## [/codeblock]
static func wait_delay_usec(timeout: float, cancel: Cancel = null) -> Variant:
	return await delay_usec(timeout).wait(cancel)

## [method all] で作成した [Async] に対して [method wait] を呼び出す短縮表記です。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## all(drains, cancel).wait(cancel)
## [/codeblock]
static func wait_all(drains: Array, cancel: Cancel = null) -> Variant:
	return await all(drains, cancel).wait(cancel)

## [method all_settled] で作成した [Async] に対して [method wait] を呼び出す短縮表記です。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## all_settled(drains, cancel).wait(cancel)
## [/codeblock]
static func wait_all_settled(drains: Array, cancel: Cancel = null) -> Variant:
	return await all_settled(drains, cancel).wait(cancel)

## [method any] で作成した [Async] に対して [method wait] を呼び出す短縮表記です。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## any(drains, cancel).wait(cancel)
## [/codeblock]
static func wait_any(drains: Array, cancel: Cancel = null) -> Variant:
	return await any(drains, cancel).wait(cancel)

## [method race] で作成した [Async] に対して [method wait] を呼び出す短縮表記です。[br]
## [br]
## [b]補足[/b][br]
## 以下と同じです:
## [codeblock]
## race(drains, cancel).wait(cancel)
## [/codeblock]
static func wait_race(drains: Array, cancel: Cancel = null) -> Variant:
	return await race(drains, cancel).wait(cancel)

## この [Async] の結果が [Async] である場合、
## 指定した回数アンラップを試みた新たな [Async] を作成します。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var async := Async.completed(Async.completed(10)) # Async に Async がネストされている
## print(await async.unwrap().wait()) # 10
## [/codeblock]
func unwrap(depth := 1, cancel: Cancel = null) -> Async:
	assert(0 <= depth)
	return \
		canceled() \
		if cancel != null and cancel.is_requested or is_canceled else \
		self \
		if depth == 0 else \
		NesinkronaUnwrapAsync.new(self, cancel, depth)

## この [Async] が完了した場合、
## 指定したコルーチン (もしくは関数) の戻り値を結果として完了する新たな [Async] を作成します。[br]
## [br]
## 前の結果を写像する場合 ([method Array.map] 的な使い方) や、
## 結果から別のコルーチンへ処理を渡す場合に使うことができます。[br]
## [br]
## [b]補足[/b][br]
## 第 1 引数 [code]coroutine[/code] は引数を 1 つ受け取る
## [Callable] でなくてはなりません。この引数には直前の結果が渡されます。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var async := Async.completed(10).then(func(result): return result * result)
## print(await async.wait()) # 100
## [/codeblock]
func then(coroutine: Callable, cancel: Cancel = null) -> Async:
	return NesinkronaThenAsync.new(self, cancel, coroutine)

## この [Async] が完了した場合、
## 指定したコルーチン (もしくは関数) を呼び出し結果を待機する新たな [Async] を作成します。[br]
## [br]
## [b]補足[/b][br]
## 第 1 引数 [code]coroutine[/code] は引数を 3 つ受け取る
## [Callable] でなくてはなりません。この引数には直前の結果、
## 完了コールバック、キャンセルコールバックが渡されます。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var async := Async.completed(10).then_callback(func(result, complete: Callable, cancel: Callable):
##     complete.call(result * result))
## print(await async.wait()) # 100
## [/codeblock]
func then_callback(coroutine: Callable, cancel: Cancel = null, unbind_cancel := false) -> Async:
	return NesinkronaThenCallbackAsync.new(self, cancel, coroutine, unbind_cancel)

## [b](アドオン内もしくは実装内でのみ使用)[/b]
## この関数ではなく [member is_completed] もしくは [member is_canceled] を
## 使うようにしてください。将来名前が変わる可能性があります。
func get_state() -> int:
	#
	# 継承先で実装する必要があります。
	#

	assert(false)
	return STATE_PENDING

## この待機可能な単位が完了もしくはキャンセルされるまで待機しその結果を返します。[br]
## [br]
## キャンセルされた場合の結果は必ず null となりますが、これは
## キャンセルされたかどうかの判断にはなりません。キャンセルされる可能性がある場合、
## [member is_completed] もしくは [member is_canceled] を確認する必要があります。[br]
## [br]
## [b]補足[/b][br]
## 状態が [STATE_PENDING] もしくは [STATE_PENDING_WITH_WAITERS] のとき
## 第 1 引数 [code]cancel[/code] に [Cancel] を指定しキャンセルを要求すると、
## 状態は [STATE_CANCELED] へ移行します。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var async: Async = ...
## var result = async.wait()
## [/codeblock]
func wait(cancel: Cancel = null) -> Variant:
	#
	# 継承先で実装する必要があります。
	#

	assert(false)
	return await null

#-------------------------------------------------------------------------------

func _to_string() -> String:
	var str: String
	match get_state():
		STATE_PENDING:
			str = "(pending)"
		STATE_PENDING_WITH_WAITERS:
			str = "(pending_with_waiters)"
		STATE_CANCELED:
			str = "(canceled)"
		STATE_COMPLETED:
			str = "(completed)"
		_:
			assert(false)
	return str + "<Async#%d>" % get_instance_id()
