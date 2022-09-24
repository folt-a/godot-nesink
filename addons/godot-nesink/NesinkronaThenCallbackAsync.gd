class_name NesinkronaThenCallbackAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

var _pending := true

func _init(
	drain: NesinkronaAwaitable,
	drain_cancel: Cancel,
	coroutine: Callable) -> void:

	assert(drain != null)
	assert(coroutine != null)
	_init_gate(
		drain,
		drain_cancel,
		coroutine)

func _init_gate(
	drain: NesinkronaAwaitable,
	drain_cancel: Cancel,
	coroutine: Callable) -> void:

	var drain_result = await drain.wait(drain_cancel)
	match drain.get_state():
		STATE_CANCELED:
			cancel_release()
			_pending = true
		STATE_COMPLETED:
			reference()
			await coroutine.call(drain_result, _complete_gate, _cancel_gate)
		_:
			assert(false) # BUG

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
