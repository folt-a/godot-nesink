class_name NesinkronaThenAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

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

	reference()

	var drain_result = await drain.wait(drain_cancel)
	match drain.get_state():
		STATE_CANCELED:
			match get_state():
				STATE_PENDING:
					cancel()
				STATE_PENDING_WITH_WAITERS:
					cancel_release()
		STATE_COMPLETED:
			var result = await coroutine.call(drain_result)
			match get_state():
				STATE_PENDING:
					complete(result)
				STATE_PENDING_WITH_WAITERS:
					complete_release(result)
		_:
			assert(false) # BUG

	unreference()

func _to_string() -> String:
	return "<NesinkronaThenAsync#%d>" % get_instance_id()
