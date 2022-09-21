class_name NesinkronaAllAsync extends NesinkronaAsyncBase

#-------------------------------------------------------------------------------

var _drain_pending: int

func _init(
	drains: Array,
	drain_cancel: Cancel) -> void:

	assert(drains != null and 0 < len(drains))
	assert(drain_cancel == null or not drain_cancel.is_requested)

	var result := []
	var drain_count := len(drains)
	_drain_pending = drain_count
	result.resize(drain_count)
	for drain_index in drain_count:
		_init_flight(
			drains[drain_index],
			drain_cancel,
			drain_index,
			result)

func _init_flight(
	drain,
	drain_cancel: Cancel,
	drain_index: int,
	result: Array) -> void:

	reference()

	var drain_result
	var drain_state: int
	if drain is NesinkronaAwaitable:
		drain_result = await drain.wait(drain_cancel)
		drain_state = drain.get_state()
	else:
		drain_result = drain
		drain_state = STATE_COMPLETED

	result[drain_index] = drain_result
	_drain_pending -= 1
	match drain_state:
		STATE_CANCELED:
			match get_state():
				STATE_PENDING:
					cancel()
				STATE_PENDING_WITH_WAITERS:
					cancel_release()
		STATE_COMPLETED:
			if _drain_pending == 0:
				match get_state():
					STATE_PENDING:
						complete(result)
					STATE_PENDING_WITH_WAITERS:
						complete_release(result)
		_:
			assert(false) # BUG

	unreference()

func _to_string() -> String:
	return "<NesinkronaWhenAllAsync#%d>" % get_instance_id()
