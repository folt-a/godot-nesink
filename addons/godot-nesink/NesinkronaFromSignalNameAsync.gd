class_name NesinkronaFromSignalNameAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------
# 定数
#---------------------------------------------------------------------------------------------------

const MAX_SIGNAL_ARGC := 5

#---------------------------------------------------------------------------------------------------

func _init(
	object: Object,
	signal_name: StringName,
	signal_argc: int) -> void:

	assert(object != null)

	match signal_argc:
#		0: object.connect(signal_name, _on_completed_0, CONNECT_ONE_SHOT)
#		1: object.connect(signal_name, _on_completed_1, CONNECT_ONE_SHOT)
#		2: object.connect(signal_name, _on_completed_2, CONNECT_ONE_SHOT)
#		3: object.connect(signal_name, _on_completed_3, CONNECT_ONE_SHOT)
#		4: object.connect(signal_name, _on_completed_4, CONNECT_ONE_SHOT)
#		5: object.connect(signal_name, _on_completed_5, CONNECT_ONE_SHOT)
		0: object.connect(signal_name, _on_completed_0)
		1: object.connect(signal_name, _on_completed_1)
		2: object.connect(signal_name, _on_completed_2)
		3: object.connect(signal_name, _on_completed_3)
		4: object.connect(signal_name, _on_completed_4)
		5: object.connect(signal_name, _on_completed_5)
		_: assert(false)

func _to_string() -> String:
	return "<NesinkronaFromSignalNameAsync#%d>" % get_instance_id()

func _on_completed_0() -> void:
	match get_state():
		STATE_PENDING:
			complete([])
		STATE_PENDING_WITH_WAITERS:
			complete_release([])

func _on_completed_1(arg1) -> void:
	match get_state():
		STATE_PENDING:
			complete([arg1])
		STATE_PENDING_WITH_WAITERS:
			complete_release([arg1])

func _on_completed_2(arg1, arg2) -> void:
	match get_state():
		STATE_PENDING:
			complete([arg1, arg2])
		STATE_PENDING_WITH_WAITERS:
			complete_release([arg1, arg2])

func _on_completed_3(arg1, arg2, arg3) -> void:
	match get_state():
		STATE_PENDING:
			complete([arg1, arg2, arg3])
		STATE_PENDING_WITH_WAITERS:
			complete_release([arg1, arg2, arg3])

func _on_completed_4(arg1, arg2, arg3, arg4) -> void:
	match get_state():
		STATE_PENDING:
			complete([arg1, arg2, arg3, arg4])
		STATE_PENDING_WITH_WAITERS:
			complete_release([arg1, arg2, arg3, arg4])

func _on_completed_5(arg1, arg2, arg3, arg4, arg5) -> void:
	match get_state():
		STATE_PENDING:
			complete([arg1, arg2, arg3, arg4, arg5])
		STATE_PENDING_WITH_WAITERS:
			complete_release([arg1, arg2, arg3, arg4, arg5])
