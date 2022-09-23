class_name NesinkronaThen2Async extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

var _landed := false

func _init(
	drain: Async,
	drain_cancel: Cancel,
	coroutine: Callable) -> void:

	_init_flight(
		drain,
		drain_cancel,
		coroutine)

func _init_flight(
	drain: Async,
	drain_cancel: Cancel,
	coroutine: Callable) -> void:

	#reference()

	var drain_result = await drain.wait(drain_cancel)
	match drain.get_state():
		STATE_CANCELED:
			match get_state():
				STATE_PENDING:
					cancel()
				STATE_PENDING_WITH_WAITERS:
					cancel_release()
			_landed = true
		STATE_COMPLETED:
			reference()
			await coroutine.call(drain_result, _complete, _cancel)
			#assert(STATE_PENDING_WITH_WAITERS < get_state())
		_:
			assert(false) # BUG

	#unreference()

func _to_string() -> String:
	return "<NesinkronaThenAsync#%d>" % get_instance_id()

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
