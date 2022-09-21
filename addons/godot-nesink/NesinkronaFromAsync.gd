class_name NesinkronaFromAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

func _init(coroutine: Callable) -> void:
	assert(coroutine != null)
	_init_flight(coroutine)

func _init_flight(coroutine: Callable) -> void:
	reference()
	var result = await coroutine.call()
	match get_state():
		STATE_PENDING:
			complete(result)
		STATE_PENDING_WITH_WAITERS:
			complete_release(result)
	unreference()

func _to_string() -> String:
	return "<NesinkronaFromAsync#%d>" % get_instance_id()
