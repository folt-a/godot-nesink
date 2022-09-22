class_name NesinkronaUnwrapAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

func _init(
	drain: Async,
	drain_cancel: Cancel,
	depth: int) -> void:

	assert(0 < depth)
	assert(drain_cancel == null or not drain_cancel.is_requested)

	_init_flight(
		drain,
		drain_cancel,
		depth)

func _init_flight(
	drain, #: Async,
	drain_cancel: Cancel,
	depth: int) -> void:

	reference()

	var drain_result = await drain.wait(drain_cancel)
	while drain_result is Async and depth != 0:
		drain = drain_result
		drain_result = await drain.wait(drain_cancel)
		depth -= 1

	match drain.get_state():
		STATE_CANCELED:
			match get_state():
				STATE_PENDING:
					cancel()
				STATE_PENDING_WITH_WAITERS:
					cancel_release()
		STATE_COMPLETED:
			match get_state():
				STATE_PENDING:
					complete(drain_result)
				STATE_PENDING_WITH_WAITERS:
					complete_release(drain_result)
		_:
			assert(false) # BUG

	unreference()

func _to_string() -> String:
	return "<NesinkronaThenAsync#%d>" % get_instance_id()
