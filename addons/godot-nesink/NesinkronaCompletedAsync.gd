class_name NesinkronaCompletedAsync extends Async

#---------------------------------------------------------------------------------------------------
# メソッド
#---------------------------------------------------------------------------------------------------

func wait(cancel: Cancel = null) -> Variant:
	return _result

func get_state() -> int:
	return STATE_COMPLETED

#---------------------------------------------------------------------------------------------------

var _result: Variant

func _init(result: Variant) -> void:
	_result = result
