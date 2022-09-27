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

# https://github.com/ydipeepo/godot-nesink/issues/4
static func normalize_drain(drain):
	if drain is Array:
		match len(drain):
#			3:
#				if drain[0] is Object and (drain[1] is String or drain[1] is StringName) and drain[2] is int:
#					return NesinkronaFromSignalNameAsync.new(drain[0], drain[1], drain[2])
			2:
#				if drain[0] is Object and (drain[1] is String or drain[1] is StringName):
#					return NesinkronaFromSignalNameAsync.new(drain[0], drain[1], 0)
				if drain[0] is Signal and drain[1] is int:
					return NesinkronaFromSignalAsync.new(drain[0], drain[1])
			1:
#				if drain[0] is Object:
#					return NesinkronaFromSignalNameAsync.new(drain[0], "completed", 0)
				if drain[0] is Signal:
					return NesinkronaFromSignalAsync.new(drain[0], 0)

#	if drain is Object:
#		return NesinkronaFromSignalNameAsync.new(drain[0], "completed", 0)

	if drain is Signal:
		return NesinkronaFromSignalAsync.new(drain, 0)

	if drain is Callable:
		return NesinkronaFromAsync.new(drain)

	return drain

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
