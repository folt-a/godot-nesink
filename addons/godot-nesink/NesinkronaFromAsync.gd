class_name NesinkronaFromAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

func _init(coroutine: Callable) -> void:
	_init_core(coroutine)

func _init_core(coroutine: Callable) -> void:
	reference()
	complete_release(await coroutine.call())
	unreference()
