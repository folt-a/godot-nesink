class_name NesinkronaAsyncGenerator extends AsyncGenerator

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

func get_state() -> int:
	return _runner.get_state()

func wait(cancel: Cancel = null):
	return await _runner.wait(cancel)

func next(value = null) -> Async:
	var next_async: Async
	if len(_set_value_queue) != 0:
		var set_value: Callable = _set_value_queue.pop_front()
		next_async = set_value.call(value)
	elif _runner.is_pending:
		next_async = Async.from_callback(func(set: Callable, cancel: Callable) -> void:
			var set_result := func(result, ran := false) -> Async:
				var yield_async: Async
				if ran:
					cancel.call()
					yield_async = NesinkronaCanon.create_canceled_async()
				else:
					set.call(result)
					yield_async = NesinkronaCanon.create_completed_async(value)
				return yield_async
			_set_result_queue.push_back(set_result))
	else:
		next_async = NesinkronaCanon.create_canceled_async()
	return next_async

#-------------------------------------------------------------------------------

var _runner: Async
var _set_result_queue: Array[Callable] = []
var _set_value_queue: Array[Callable] = []

func _init(coroutine: Callable) -> void:
	assert(coroutine != null)
	_runner = Async.from(func():
		var result = await coroutine.call(_yield)
		for set_result in _set_result_queue:
			set_result.call(null, true)
		for set_value in _set_value_queue:
			set_value.call(null, true)
		_set_result_queue.clear()
		_set_value_queue.clear()
		return result)

func _yield(result = null) -> Async:
	var yield_async: Async
	if len(_set_result_queue) != 0:
		var set_result: Callable = _set_result_queue.pop_front()
		yield_async = set_result.call(result)

	# https://github.com/ydipeepo/godot-nesink/issues/3
	# コンストラクタが完走する前にここへ到達する可能性があるため、
	# _runner == null の条件を追加した。
	elif _runner == null or _runner.is_pending:
		yield_async = Async.from_callback(func(set: Callable, cancel: Callable) -> void:
			var set_value := func(value, ran := false) -> Async:
				var next_async: Async
				if ran:
					cancel.call()
					next_async = NesinkronaCanon.create_canceled_async()
				else:
					set.call(value)
					next_async = NesinkronaCanon.create_completed_async(result)
				return next_async
			_set_value_queue.push_back(set_value))
	else:
		yield_async = NesinkronaCanon.create_canceled_async()
	return yield_async
