class_name NesinkronaDelayAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------
# 定数
#---------------------------------------------------------------------------------------------------

const MIN_TIMEOUT := 0.0

#---------------------------------------------------------------------------------------------------

func _init(timeout: float) -> void:
	assert(MIN_TIMEOUT <= timeout)
#	NesinkronaCanon.create_timer(timeout).timeout.connect(_on_timeout.bind(timeout), CONNECT_ONE_SHOT)
	NesinkronaCanon.create_timer(timeout).timeout.connect(_on_timeout.bind(timeout))

func _on_timeout(timeout: float) -> void:
	match get_state():
		STATE_PENDING:
			complete(timeout)
		STATE_PENDING_WITH_WAITERS:
			complete_release(timeout)

func _to_string() -> String:
	return "<NesinkronaDelayAsync#%d>" % get_instance_id()
