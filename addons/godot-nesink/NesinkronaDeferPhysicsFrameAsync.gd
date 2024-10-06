class_name NesinkronaDeferPhysicsFrameAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

func _init() -> void:
	get_tree().physics_frame.connect(_on_completed)

func _on_completed() -> void:
	get_tree().physics_frame.disconnect(_on_completed)
	if is_pending:
		complete_release(null)
