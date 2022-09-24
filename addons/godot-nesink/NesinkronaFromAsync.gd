class_name NesinkronaFromAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

func _init(coroutine: Callable) -> void:
	assert(coroutine != null)
	_init_gate(coroutine)

func _init_gate(coroutine: Callable) -> void:
	reference()
	complete_release(await coroutine.call())
	unreference()
