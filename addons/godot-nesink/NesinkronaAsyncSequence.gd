class_name NesinkronaAsyncSequence extends AsyncSequence

#
# テスト中。バグがある
#

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

func next(
	value = null,
	cancel: Cancel = null) -> Async:

	var yield_awaiter := Async \
		.from_signal(_release_next, 1) \
		.then(_first)
	_release_yield.emit(value)
	return yield_awaiter

func wait(cancel: Cancel = null):
	return await _runner.wait(cancel)

func get_state() -> int:
	return _runner.get_state()

#-------------------------------------------------------------------------------

signal _release_yield(value)
signal _release_next(result)

var _runner: Async
var _runner_cancel := Cancel.new()

func _init(generator: Callable) -> void:
	assert(generator != null)
	_runner = Async.from(generator.bind(_yield))

func _to_string() -> String:
	return "<AsyncSequence#%d>" % get_instance_id()

func _yield(result = null):

	var yield_awaiter := Async \
		.from_signal(_release_yield, 1) \
		.then(_first)
	var value = await yield_awaiter.wait(_runner_cancel)
	_release_next.emit(result)
	return value

static func _first(array: Array):
	return array[0]
