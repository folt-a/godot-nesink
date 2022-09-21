class_name NesinkronaAsyncBase extends Async

#---------------------------------------------------------------------------------------------------
# メソッド
#---------------------------------------------------------------------------------------------------

func wait(cancel: Cancel = null):
	if _state <= STATE_PENDING_WITH_WAITERS:
		_state = STATE_PENDING_WITH_WAITERS
		if cancel:
			await _wait_with_cancel(cancel)
		else:
			await _wait()
	return _result

func get_state() -> int:
	return _state

func complete(result) -> void:
	assert(_state <= STATE_PENDING_WITH_WAITERS)
	_result = result
	_state = STATE_COMPLETED

func complete_release(result) -> void:
	assert(_state <= STATE_PENDING_WITH_WAITERS)
	_result = result
	_state = STATE_COMPLETED
	_release.emit()

func cancel() -> void:
	assert(_state <= STATE_PENDING_WITH_WAITERS)
	_state = STATE_CANCELED

func cancel_release() -> void:
	assert(_state <= STATE_PENDING_WITH_WAITERS)
	_state = STATE_CANCELED
	_release.emit()

#---------------------------------------------------------------------------------------------------

signal _release

var _state := STATE_PENDING
var _result

func _wait() -> void:
	assert(_state == STATE_PENDING_WITH_WAITERS)
	await _release

func _wait_with_cancel(cancel: Cancel) -> void:
	assert(_state == STATE_PENDING_WITH_WAITERS)
	if cancel.is_requested:
		_on_cancel_requested()
	else:
#		cancel.requested.connect(_on_cancel_requested, CONNECT_ONE_SHOT)
		cancel.requested.connect(_on_cancel_requested)
		await _release
		cancel.requested.disconnect(_on_cancel_requested)

func _on_cancel_requested() -> void:
	if _state <= STATE_PENDING_WITH_WAITERS:
		assert(_state == STATE_PENDING_WITH_WAITERS)
		cancel_release()
