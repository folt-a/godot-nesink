class_name NesinkronaThenCallbackAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------

var _pending := true

func _init(
	drain: Async,
	drain_cancel: Cancel,
	coroutine: Callable,
	unbind_cancel: bool) -> void:

	assert(drain != null)

	if unbind_cancel:
		coroutine = coroutine.unbind(1)
	_init_core(drain, drain_cancel, coroutine)

func _init_core(drain: Async, drain_cancel: Cancel, coroutine: Callable) -> void:
	var drain_result: Variant = await drain.wait(drain_cancel)
	match drain.get_state():
		STATE_CANCELED:
			cancel_release()
			_pending = true
		STATE_COMPLETED:
			reference()
			await coroutine.call(drain_result, _complete_core, _cancel_core)
		_:
			assert(false, "BUG")

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
