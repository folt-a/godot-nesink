class_name NesinkronaRaceAsync extends NesinkronaAsyncBase

#-------------------------------------------------------------------------------

var _pending_drains: int

func _init(
	drains: Array,
	drain_cancel: Cancel) -> void:

	assert(drains != null and 0 < len(drains))

	var drain_count := len(drains)

	#
	# どれか一つのドレインの待機中ではなくなるまで待機します。
	#
	# どれか一つのドレインが待機中ではなくなった -> 結果を Async として設定して完了する
	#

	_pending_drains = drain_count
	for drain_index in drain_count:
		_init_gate(
			normalize_drain(drains[drain_index]),
			drain_cancel)

func _init_gate(
	drain,
	drain_cancel: Cancel) -> void:

	if drain is NesinkronaAwaitable:
		reference()
		var drain_result = await drain.wait(drain_cancel)
		_pending_drains -= 1
		match drain.get_state():
			STATE_CANCELED:
				if _pending_drains == 0:
					complete_release(NesinkronaCanon.create_canceled_async())
			STATE_COMPLETED:
				complete_release(NesinkronaCanon.create_completed_async(drain_result))
			_:
				assert(false) # BUG
		unreference()

	else:
		complete_release(NesinkronaCanon.create_completed_async(drain))
