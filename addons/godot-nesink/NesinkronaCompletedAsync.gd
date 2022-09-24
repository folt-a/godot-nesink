class_name NesinkronaCompletedAsync extends Async

#---------------------------------------------------------------------------------------------------
# メソッド
#---------------------------------------------------------------------------------------------------

func wait(cancel: Cancel = null):
	return _result

func get_state() -> int:
	return STATE_COMPLETED

#---------------------------------------------------------------------------------------------------

var _result

func _init(result) -> void:
	_result = result
