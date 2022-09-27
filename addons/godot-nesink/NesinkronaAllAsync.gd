class_name NesinkronaAllAsync extends NesinkronaAsyncBase

#-------------------------------------------------------------------------------

var _pending_drains: int

func _init(
	drains: Array,
	drain_cancel: Cancel) -> void:

	assert(drains != null and 0 < len(drains))
	assert(drain_cancel == null or not drain_cancel.is_requested)

	var drain_count := len(drains)
	var result := []
	result.resize(drain_count)

	#
	# すべてのドレインが完了するまで待機します。
	#
	# すべてのドレインが完了した -> 結果が配列に含まれたものを設定して完了する
	# 他 -> キャンセル
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
		result[drain_index] = await drain.wait(drain_cancel)
		_pending_drains -= 1
		match drain.get_state():
			STATE_CANCELED:
				cancel_release()
			STATE_COMPLETED:
				if _pending_drains == 0:
					complete_release(result)
			_:
				assert(false) # BUG
		unreference()

	else:
		result[drain_index] = drain
		_pending_drains -= 1
		if _pending_drains == 0:
			complete_release(result)
