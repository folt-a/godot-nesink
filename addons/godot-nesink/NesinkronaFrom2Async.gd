class_name NesinkronaFrom2Async extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

var _landed := false

func _init(coroutine: Callable) -> void:
	assert(coroutine != null)
	_init_flight(coroutine)

func _init_flight(coroutine: Callable) -> void:
	reference()
	await coroutine.call(_complete, _cancel)
	#assert(STATE_PENDING_WITH_WAITERS < get_state())
	#unreference()

func _to_string() -> String:
	return "<NesinkronaFromAsync#%d>" % get_instance_id()

func _complete(result = null) -> void:
	match get_state():
		STATE_PENDING:
			complete(result)
		STATE_PENDING_WITH_WAITERS:
			complete_release(result)
	if not _landed:
		_landed = true
		unreference()

func _cancel() -> void:
	match get_state():
		STATE_PENDING:
			cancel()
		STATE_PENDING_WITH_WAITERS:
			cancel_release()
	if not _landed:
		_landed = true
		unreference()
