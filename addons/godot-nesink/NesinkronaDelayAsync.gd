class_name NesinkronaDelayAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------
# 定数
#---------------------------------------------------------------------------------------------------

const MIN_TIMEOUT := 0.0

#---------------------------------------------------------------------------------------------------

var _timeout: float

func _init(timeout: float) -> void:
	assert(MIN_TIMEOUT <= timeout)
	_timeout = timeout
	NesinkronaCanon.create_timer(timeout).timeout.connect(_on_timeout)

func _on_timeout() -> void:
	complete_release(_timeout)
