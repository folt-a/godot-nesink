class_name NesinkronaDeferIdleAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

func _init() -> void:
	_on_completed.call_deferred()

func _on_completed() -> void:
	if is_pending:
		complete_release(null)
