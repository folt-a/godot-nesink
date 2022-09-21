class_name NesinkronaRaceAsync extends NesinkronaAsyncBase

#-------------------------------------------------------------------------------

var _drain_pending: int

func _init(
	drains: Array,
	drain_cancel: Cancel) -> void:

	assert(drains != null and 0 < len(drains))
	assert(drain_cancel == null or not drain_cancel.is_requested)

	var drain_count := len(drains)
	_drain_pending = drain_count
	for drain_index in drain_count:
		_init_flight(
			drains[drain_index],
			drain_cancel)

func _init_flight(
	drain,
	drain_cancel: Cancel) -> void:

	reference()

	var drain_result
	var drain_state: int
	if drain is NesinkronaAwaitable:
		drain_result = await drain.wait(drain_cancel)
		drain_state = drain.get_state()
		match drain_state:
			STATE_CANCELED:
				drain_result = drain if drain is Async else \
					NesinkronaCanon.create_canceled()
			STATE_COMPLETED:
				drain_result = drain if drain is Async else \
					NesinkronaCompletedAsync.new(drain_result)
			_:
				assert(false) # BUG
	else:
		drain_result = NesinkronaCompletedAsync.new(drain)
		drain_state = STATE_COMPLETED

	_drain_pending -= 1
	match drain_state:
		STATE_COMPLETED:
			match get_state():
				STATE_PENDING:
					complete(drain_result)
				STATE_PENDING_WITH_WAITERS:
					complete_release(drain_result)
		STATE_CANCELED:
			if _drain_pending == 0:
				match get_state():
					STATE_PENDING:
						cancel()
					STATE_PENDING_WITH_WAITERS:
						cancel_release()

	unreference()

func _to_string() -> String:
	return "<NesinkronaWhenAnyAsync#%d>" % get_instance_id()
