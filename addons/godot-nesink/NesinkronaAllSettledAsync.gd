class_name NesinkronaAllSettledAsync extends NesinkronaAsyncBase

#-------------------------------------------------------------------------------

var _pending_drains: int

func _init(drains: Array, drain_cancel: Cancel) -> void:
	assert(not drains.is_empty())

	var drain_count := drains.size()
	var result := []
	result.resize(drain_count)

	_pending_drains = drain_count
	for drain_index: int in drain_count:
		_init_core(
			normalize_drain(drains[drain_index]),
			drain_cancel,
			drain_index,
			result)

func _init_core(
	drain: Variant,
	drain_cancel: Cancel,
	drain_index: int,
	result: Array) -> void:

	if drain is Async:
		reference()
		var drain_result: Variant = await drain.wait(drain_cancel)
		match drain.get_state():
			STATE_CANCELED:
				result[drain_index] = NesinkronaCanceledAsync.new()
			STATE_COMPLETED:
				result[drain_index] = NesinkronaCompletedAsync.new(drain_result)
			_:
				assert(false, "BUG")
		_pending_drains -= 1
		if _pending_drains == 0:
			complete_release(result)
		unreference()
	else:
		result[drain_index] = NesinkronaCompletedAsync.new(drain)
		_pending_drains -= 1
		if _pending_drains == 0:
			complete_release(result)
