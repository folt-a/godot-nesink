class_name NesinkronaAllSettledAsync extends NesinkronaAsyncBase

#-------------------------------------------------------------------------------

var _pending_drains: int

func _init(
	drains: Array,
	drain_cancel: Cancel) -> void:

	assert(drains != null and 0 < len(drains))

	var drain_count := len(drains)
	var result := []
	result.resize(drain_count)

	#
	# すべてのドレインが待機中ではなくなるまで待機します。
	#
	# すべてのドレインが待機中ではなくなった -> 結果を含む Async の配列を設定して完了する
	#

	_pending_drains = drain_count
	for drain_index in drain_count:
		_init_gate(
			normalize_drain(drains[drain_index]),
			drain_cancel,
			drain_index,
			result)

func _init_gate(
	drain,
	drain_cancel: Cancel,
	drain_index: int,
	result: Array) -> void:

	if drain is NesinkronaAwaitable:
		reference()
		var drain_result = await drain.wait(drain_cancel)
		match drain.get_state():
			STATE_CANCELED:
				result[drain_index] = NesinkronaCanon.create_canceled_async()
			STATE_COMPLETED:
				result[drain_index] = NesinkronaCanon.create_completed_async(drain_result)
			_:
				assert(false) # BUG
		_pending_drains -= 1
		if _pending_drains == 0:
			complete_release(result)
		unreference()

	else:
		result[drain_index] = NesinkronaCanon.create_completed_async(drain)
		_pending_drains -= 1
		if _pending_drains == 0:
			complete_release(result)
