class_name NesinkronaCanceledAsync extends Async

#---------------------------------------------------------------------------------------------------
# メソッド
#---------------------------------------------------------------------------------------------------

func wait(cancel: Cancel = null) -> Variant:
	return null

func get_state() -> int:
	return STATE_CANCELED
