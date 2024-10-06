class_name NesinkronaThenAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

func _init(drain: Async, drain_cancel: Cancel, coroutine: Callable) -> void:
	assert(drain != null)

	_init_core(drain, drain_cancel, coroutine)

func _init_core(drain: Async, drain_cancel: Cancel, coroutine: Callable) -> void:
	reference()
	var drain_result: Variant = await drain.wait(drain_cancel)
	match drain.get_state():
		STATE_CANCELED:
			cancel_release()
		STATE_COMPLETED:
			complete_release(await coroutine.call(drain_result))
		_:
			assert(false, "BUG")
	unreference()
