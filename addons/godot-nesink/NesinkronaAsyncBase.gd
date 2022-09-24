class_name NesinkronaAsyncBase extends Async

#---------------------------------------------------------------------------------------------------
# メソッド
#---------------------------------------------------------------------------------------------------

func get_state() -> int:
	return _state

func wait(cancel: Cancel = null):
	if _state == STATE_PENDING:
		_state = STATE_PENDING_WITH_WAITERS
	if _state == STATE_PENDING_WITH_WAITERS:
		if cancel:
			await _wait_with_cancel(cancel)
		else:
			await _wait()
	return _result

func complete_release(result) -> void:
	match _state:
		STATE_PENDING:
			_result = result
			_state = STATE_COMPLETED
		STATE_PENDING_WITH_WAITERS:
			_result = result
			_state = STATE_COMPLETED
			_release.emit()

func cancel_release() -> void:
	match _state:
		STATE_PENDING:
			_state = STATE_CANCELED
		STATE_PENDING_WITH_WAITERS:
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
		cancel_release()
		return

	cancel.reference()
	cancel.requested.connect(_on_cancel_requested)
	await _release
	cancel.requested.disconnect(_on_cancel_requested)
	cancel.unreference()

func _on_cancel_requested() -> void:
	assert(_state <= STATE_PENDING_WITH_WAITERS)
	cancel_release()
