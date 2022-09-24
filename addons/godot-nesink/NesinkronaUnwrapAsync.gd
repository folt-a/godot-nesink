class_name NesinkronaUnwrapAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

func _init(
	drain: NesinkronaAwaitable,
	drain_cancel: Cancel,
	depth: int) -> void:

	assert(0 < depth)
	assert(drain_cancel == null or not drain_cancel.is_requested)
	_init_flight(
		drain,
		drain_cancel,
		depth)

func _init_flight(
	drain,
	drain_cancel: Cancel,
	depth: int) -> void:

	reference()
	var drain_result = await drain.wait(drain_cancel)
	while drain_result is NesinkronaAwaitable and depth != 0:
		drain = drain_result
		drain_result = await drain.wait(drain_cancel)
		depth -= 1
	match drain.get_state():
		STATE_CANCELED:
			cancel_release()
		STATE_COMPLETED:
			complete_release(drain_result)
		_:
			assert(false) # BUG
	unreference()
