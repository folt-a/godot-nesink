class_name NesinkronaDeferProcessFrameAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

func _init() -> void:
	get_tree().process_frame.connect(_on_completed)

func _on_completed() -> void:
	get_tree().process_frame.disconnect(_on_completed)
	if is_pending:
		complete_release(null)
