## 結果を複数生成する待機可能な単位です。
class_name AsyncSequence extends NesinkronaAwaitable

# !!!!!!!テスト中!!!!!!!!

## コルーチンを AsyncSequence に変換します。
##
## Usage:
##     [codeblock]
##     var seq := AsyncSequence.from(func (yield_):
##         print(await yield_.call("y1"))
##         print(await yield_.call("y2"))
##         return "fin")
##     print(await seq.next("n1"))
##     print(await seq.next("n2"))
##     print(await seq.wait())
##     # "y1"
##     # "n1"
##     # "y2"
##     # "n2"
##     # "fin"
##     [/codeblock]
static func from(coroutine: Callable) -> AsyncSequence:
	assert(coroutine != null)
	return AsyncSequence.new(coroutine)

## コルーチンから 1 つの結果を受け取り、指定した値とともに処理を再開させます。
func next(
	value = null,
	cancel: Cancel = null):

	var yield_awaiter := Async.from_signal(_sync_yield, 1).then(_first)
	_sync_next.emit(value)
	return await yield_awaiter.wait(cancel)

## この AsyncSequence が完了もしくはキャンセルされるまで待機します。
func wait(cancel: Cancel = null):
	return await _runner.wait(cancel)

func get_state() -> int:
	return _runner.get_state()

#-------------------------------------------------------------------------------

signal _sync_next(value)
signal _sync_yield(result)

var _runner: Async

func _init(coroutine: Callable) -> void:
	assert(coroutine != null)
	_runner = Async.from(coroutine.bind(_yield_context))

func _to_string() -> String:
	return "<AsyncSequence#%d>" % get_instance_id()

static func _first(array: Array):
	return array[0]

func _yield_context(
	result = null,
	cancel: Cancel = null):

	var value = await Async.from_signal(_sync_next, 1).then(_first).wait(cancel)
	_sync_yield.emit(result)
	return value
