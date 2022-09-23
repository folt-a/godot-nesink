class_name NesinkronaAsyncSequence extends AsyncSequence

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

func next(value = null) -> Async:
	return Async.from_2(func(set: Callable, cancel: Callable) -> void:
		var sync := func(result, request_cancel := false) -> void:
			if request_cancel:
				cancel.call()
			else:
				set.call(result)
		_sync_queue.push_back(sync)
		_sync_yield.emit())

func wait(cancel: Cancel = null):
	if cancel:
		if cancel.is_requested:
			_cancel_exchange()
		else:
			cancel.requested.connect(_cancel_exchange)
	return await _generator_async.wait(cancel)

func get_state() -> int:
	return _generator_async.get_state()

#-------------------------------------------------------------------------------

signal _sync_yield

var _sync_cancel := Cancel.new()
var _sync_queue: Array[Callable] = []
var _generator_async: Async

func _init(generator: Callable) -> void:
	assert(generator != null)
	_generator_async = Async.from(generator.bind(_yield))

func _to_string() -> String:
	return "<NesinkronaAsyncSequence#%d>" % get_instance_id()

func _cancel_exchange() -> void:
	_sync_cancel.request()
	for sync in _sync_queue:
		sync.call(null, true)
	_sync_queue.clear()

func _yield(result = null) -> Async:
	return Async.from_2(func(set: Callable, cancel: Callable) -> void:
		if len(_sync_queue) == 0:
			await Async.from_signal(_sync_yield).wait(_sync_cancel)
		if _sync_cancel.is_requested:
			cancel.call()
		else:
			var sync: Callable = _sync_queue.pop_front()
			set.call(sync.call(result)))

static func _through(value):
	return value
