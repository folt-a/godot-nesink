class_name NesinkronaThenAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

func _init(
	drain: NesinkronaAwaitable,
	drain_cancel: Cancel,
	coroutine: Callable) -> void:

	assert(drain != null)
	assert(coroutine != null)
	super._init()
	_init_gate(
		drain,
		drain_cancel,
		coroutine)

func _init_gate(
	drain: NesinkronaAwaitable,
	drain_cancel: Cancel,
	coroutine: Callable) -> void:

	reference()
	var drain_result = await drain.wait(drain_cancel)
	match drain.get_state():
		STATE_CANCELED:
			cancel_release()
		STATE_COMPLETED:
			complete_release(await coroutine.call(drain_result))
		_:
			assert(false) # BUG
	unreference()
