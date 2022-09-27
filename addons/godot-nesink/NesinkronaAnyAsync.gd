class_name NesinkronaAnyAsync extends NesinkronaAsyncBase

#-------------------------------------------------------------------------------

var _pending_drains: int

func _init(
	drains: Array,
	drain_cancel: Cancel) -> void:

	assert(drains != null and 0 < len(drains))
	assert(drain_cancel == null or not drain_cancel.is_requested)

	var drain_count := len(drains)

	#
	# どれか一つのドレインが完了するまで待機します。
	#
	# どれか一つのドレインが完了した -> 結果を設定して完了する
	# 他 -> キャンセル
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
					cancel_release()
			STATE_COMPLETED:
				complete_release(drain_result)
			_:
				assert(false) # BUG
		unreference()

	else:
		_pending_drains -= 1
		complete_release(drain)
