class_name NesinkronaAsyncIterator extends AsyncIterator

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

func get_state() -> int:
	return _runner.get_state()

func wait(cancel: Cancel = null):
	return await _runner.wait(cancel)

func next() -> Async:
	return \
		NesinkronaCanon.create_completed_async(_result_queue.pop_front()) \
		if len(_result_queue) != 0 else \
		Async.from_callback(func(set: Callable, cancel: Callable) -> void:
			var set_result := func(result, ran := false) -> void:
				if ran:
					cancel.call()
				else:
					set.call(result)
			_set_result_queue.push_back(set_result)) \
		if _runner.is_pending else \
		NesinkronaCanon.create_canceled_async()

#-------------------------------------------------------------------------------

var _runner: Async
var _set_result_queue: Array[Callable] = []
var _result_queue: Array = []

func _init(coroutine: Callable) -> void:
	assert(coroutine != null)
	_runner = Async.from(func():
		var result = await coroutine.call(_yield)
		for set_result in _set_result_queue:
			set_result.call(null, true)
		_set_result_queue.clear()
		return result)

func _yield(result = null) -> void:
	if len(_set_result_queue) != 0:
		var set_result: Callable = _set_result_queue.pop_front()
		set_result.call(result)
	else:
		_result_queue.push_back(result)
