class_name NesinkronaFromCallbackAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

var _pending := true

func _init(coroutine: Callable, unbind_cancel: bool) -> void:
	if unbind_cancel:
		coroutine = coroutine.unbind(1)
	_init_core(coroutine)

func _init_core(coroutine: Callable) -> void:
	reference()
	await coroutine.call(_complete_core, _cancel_core)

func _complete_core(result: Variant = null) -> void:
	if _pending:
		_pending = false
		complete_release(result)
		unreference()

func _cancel_core() -> void:
	if _pending:
		_pending = false
		cancel_release()
		unreference()
