class_name NesinkronaRaceAsync extends NesinkronaAsyncBase

#-------------------------------------------------------------------------------

var _pending_drains: int

func _init(drains: Array, drain_cancel: Cancel) -> void:
	assert(not drains.is_empty())

	var drain_count := drains.size()

	_pending_drains = drain_count
	for drain_index: int in drain_count:
		_init_core(
			normalize_drain(drains[drain_index]),
			drain_cancel)

func _init_core(drain: Variant, drain_cancel: Cancel) -> void:
	if drain is Async:
		reference()
		var drain_result: Variant = await drain.wait(drain_cancel)
		_pending_drains -= 1
		match drain.get_state():
			STATE_CANCELED:
				if _pending_drains == 0:
					complete_release(NesinkronaCanceledAsync.new())
			STATE_COMPLETED:
				complete_release(NesinkronaCompletedAsync.new(drain_result))
			_:
				assert(false, "BUG")
		unreference()
	else:
		complete_release(NesinkronaCompletedAsync.new(drain))
