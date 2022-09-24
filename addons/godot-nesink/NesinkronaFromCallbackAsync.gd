class_name NesinkronaFromCallbackAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

var _pending := true

func _init(coroutine: Callable) -> void:
	assert(coroutine != null)
	_init_gate(coroutine)

func _init_gate(coroutine: Callable) -> void:
	reference()
	await coroutine.call(_complete_gate, _cancel_gate)

func _complete_gate(result = null) -> void:
	if _pending:
		_pending = false
		complete_release(result)
		unreference()

func _cancel_gate() -> void:
	if _pending:
		_pending = false
		cancel_release()
		unreference()
