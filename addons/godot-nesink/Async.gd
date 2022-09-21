## 結果を 1 つ生成する待機可能な単位です。
class_name Async extends NesinkronaAwaitable

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

## ジェネレータ関数 (yield 関数を引数に取るコルーチン) を [AsyncSequence] に変形します。
##
## [AsyncSequence.from] への短縮表記です。
##
## Usage:
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
static func sequence(coroutine: Callable) -> AsyncSequence:
	assert(coroutine != null)
	return AsyncSequence.from(coroutine)

## 完了した状態の [Async] を作成します。
##
## Usage:
##     [codeblock]
##     var async := Async.completed("result")
##     assert(async.is_completed)
##     assert(await async.wait() == "result")
##     [/codeblock]
static func completed(result = null) -> Async:
	return NesinkronaCompletedAsync.new(result)

## キャンセルされた状態の [Async] を返します。
##
## Usage:
##     [codeblock]
##     var async := Async.canceled()
##     assert(async.is_canceled)
##     assert(await async.wait() == null)
##     [/codeblock]
static func canceled() -> Async:
	return NesinkronaCanon.create_canceled()

## コルーチン (もしくは関数) の戻り値を格納し完了する [Async] を作成します。
##
## Usage:
##     [codeblock]
##     var async1 := Async.from(func ():
##         await get_tree().create_timer(1.0).timeout)
##     var async2 := Async.from(func ():
##         await get_tree().create_timer(1.0).timeout
##         return 123)
##     print(await async1.wait()) # <null>
##     print(await async2.wait()) # 123
##     [/codeblock]
static func from(coroutine: Callable) -> Async:
	assert(coroutine != null)
	return NesinkronaFromAsync.new(coroutine)

## シグナルの引数を配列として格納し完了する [Async] を作成します。
##
## Usage:
##     [codeblock]
##     signal my_event_0
##     signal my_event_1(a)
##     signal my_event_2(a, b)
##
##     var async0 := Async.from_signal(my_event_0)
##     var async1 := Async.from_signal(my_event_1, 1) # シグナル引数の数を明示する必要があります
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

## オブジェクトとシグナル名から、
## シグナルの引数を配列として格納し完了する [Async] を作成します。
##
## Usage:
##     [codeblock]
##     signal my_event_0
##     signal my_event_1(a)
##     signal my_event_2(a, b)
##
##     var async0 := Async.from_signal_name(self, "my_event_0")
##     var async1 := Async.from_signal_name(self, "my_event_1", 1) # シグナル引数の数を明示する必要があります
##     var async2 := Async.from_signal_name(self, "my_event_2", 2) # 同上
##     print(await async0.wait()) # []
##     print(await async1.wait()) # [1]
##     print(await async2.wait()) # [1, 2]
##
##     my_event_0.emit()     # どこかにこのようなエミッションがあるとします
##     my_event_1.emit(1)    # 同上
##     my_event_2.emit(1, 2) # 同上
##     [/codeblock]
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

## タイムアウトすると完了する [Async] を返します。
##
## Usage:
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

## タイムアウト (ms) すると完了する [Async] を返します。
static func delay_msec(timeout: float) -> Async:
	return delay(timeout / 1_000.0)

## タイムアウト (us) すると完了する [Async] を返します。
static func delay_usec(timeout: float) -> Async:
	return delay(timeout / 1_000_000.0)

## すべての入力の完了を待機しその結果を配列として格納し完了する [Async] を作成します。
##
## [Async] や [AsyncSequence] は完了を待機しその結果が格納されます。
## そのほかの値はそのまま格納されます。
## [Async] や [AsyncSequence] を含む場合、どれか一つでも
## キャンセルされると結果はキャンセルされた [Async] となります。
## もし完了やキャンセルを問わず待機が終わったことのみを待つ必要がある場合は
## このメソッドではなく [method all_settled] を使います。
##
## Usage:
##     [codeblock]
##     var async := Async.all([
##         Async.delay(1.0),
##         Async.delay(1.5),
##         Async.delay(2.0),
##         true,
##         "aaa")
##     print(await async.wait()) # [1.0, 1.5, 2.0, true, "aaa"]
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

## 完了やキャンセルを問わずすべての入力を待機し
## その結果を [Async] の配列として格納し完了する [Async] を作成します。
##
## [Async] は完了もしくはキャンセルを待機しそのまま [Async] として格納されます。
## [AsyncSequence] は完了もしくはキャンセルを待機し [Async] に変換され格納されます。
## そのほかの値は完了済みの [Async] に変換され格納されます。
## 
## Usage:
##     [codeblock]
##     var async := Async.all_settled([
##         Async.delay(1.0),
##         Async.delay(2.0),
##         10,
##         20,
##     ])
##     print(await async.wait()) # [<Async#...>, <Async#...>, 10, 20]
##     [/codeblock]
static func all_settled(
	drains: Array,
	cancel: Cancel = null) -> Async:

	return \
		NesinkronaCanon.create_canceled() \
		if cancel and cancel.is_requested else \
		NesinkronaCompletedAsync.new([]) \
		if drains == null or 0 == len(drains) else \
		NesinkronaAllSettledAsync.new(drains, cancel)

## 入力のうち最初に完了したその結果を格納し完了する [Async] を作成します。
##
## もし完了やキャンセルを問わず待機が終わったことのみを待つ必要がある場合は
## このメソッドではなく [method race] を使います。
##
## Usage:
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

## 入力のうち最初に完了もしくはキャンセルされたその結果を格納した [Async] を作成します。
##
## Usage:
##     [codeblock]
##     var async := Async.race([
##         Async.delay(1.0),
##         Async.delay(2.0),
##         Async.delay(3.0),
##     ])
##     async = await async.wait()
##     print(async.is_completed) # true
##     print(async.wait()) # 1.0
##     [/codeblock]
static func race(
	drains: Array,
	cancel: Cancel = null) -> Async:

	return \
		NesinkronaCanon.create_canceled() \
		if cancel and cancel.is_requested or drains == null or 0 == len(drains) else \
		NesinkronaRaceAsync.new(drains, cancel)

## [method delay] の戻り値に対し [method wait] を呼び出す短縮表記です。
static func wait_delay(
	timeout: float,
	cancel: Cancel = null):

	return await delay(timeout).wait(cancel)

## [method delay_msec] の戻り値に対し [method wait] を呼び出す短縮表記です。
static func wait_delay_msec(
	timeout: float,
	cancel: Cancel = null):

	return await delay_msec(timeout).wait(cancel)

## [method all] の戻り値に対し [method wait] を呼び出す短縮表記です。
static func wait_all(
	drains: Array,
	cancel: Cancel = null):

	return await all(drains, cancel).wait(cancel)

## [method all_settled] の戻り値に対し [method wait] を呼び出す短縮表記です。
static func wait_all_settled(
	drains: Array,
	cancel: Cancel = null):

	return await all_settled(drains, cancel).wait(cancel)

## [method any] の戻り値に対し [method wait] を呼び出す短縮表記です。
static func wait_any(
	drains: Array,
	cancel: Cancel = null):

	return await any(drains, cancel).wait(cancel)

## [method race] の戻り値に対し [method wait] を呼び出す短縮表記です。
static func wait_race(
	drains: Array,
	cancel: Cancel = null):

	return await race(drains, cancel).wait(cancel)

## 継続するコルーチン (もしくは関数) を接続した新たな [Async] を返します。
##
## 写像する場合 (Array.map 的な使い方) や、
## 別のコルーチンを接続する場合に使います。
##
## Usage:
##     [codeblock]
##     var async := Async.completed(10).then(func (result): return result * result)
##     print(await async.wait()) # 100
##     [/codeblock]
func then(
	coroutine: Callable,
	cancel: Cancel = null) -> Async:

	assert(coroutine != null)
	return NesinkronaThenAsync.new(self, cancel, coroutine)

## 結果が [Async] である場合、指定した回数アンラップを試みたものを返す新たな [Async] を返します。
##
## Usage:
##     [codeblock]
##     var async := Async.completed(Async.completed(10)).unwrap()
##     print(await async.wait()) # 10
##     [/codeblock]
func unwrap(
	depth := 1,
	cancel: Cancel = null) -> Async:

	assert(0 <= depth)
	return \
		self \
		if depth == 0 else \
		then(func (result):
			while depth != 0:
				if not result is Async:
					break
				depth -= 1
				result = await result.wait(cancel)
			return result, cancel)
