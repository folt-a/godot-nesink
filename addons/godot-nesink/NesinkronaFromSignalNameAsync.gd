class_name NesinkronaFromSignalNameAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------
# 定数
#---------------------------------------------------------------------------------------------------

const MAX_SIGNAL_ARGC := 5

#---------------------------------------------------------------------------------------------------

var _object: Object
var _signal_name: StringName

func _init(
	object: Object,
	signal_name: StringName,
	signal_argc: int) -> void:

	assert(object != null)
	assert(signal_argc <= MAX_SIGNAL_ARGC)

	_object = object
	_signal_name = signal_name

	if is_instance_valid(_object):
		match signal_argc:
			0: _object.connect(_signal_name, _on_completed_0)
			1: _object.connect(_signal_name, _on_completed_1)
			2: _object.connect(_signal_name, _on_completed_2)
			3: _object.connect(_signal_name, _on_completed_3)
			4: _object.connect(_signal_name, _on_completed_4)
			5: _object.connect(_signal_name, _on_completed_5)

	else:
		cancel_release()

func _on_completed_0() -> void:
	if is_instance_valid(_object):
		_object.disconnect(_signal_name, _on_completed_0)
		_object = null

	if is_pending:
		complete_release([])

func _on_completed_1(arg1) -> void:
	if is_instance_valid(_object):
		_object.disconnect(_signal_name, _on_completed_1)
		_object = null

	if is_pending:
		complete_release([arg1])

func _on_completed_2(arg1, arg2) -> void:
	if is_instance_valid(_object):
		_object.disconnect(_signal_name, _on_completed_2)
		_object = null

	if is_pending:
		complete_release([arg1, arg2])

func _on_completed_3(arg1, arg2, arg3) -> void:
	if is_instance_valid(_object):
		_object.disconnect(_signal_name, _on_completed_3)
		_object = null

	if is_pending:
		complete_release([arg1, arg2, arg3])

func _on_completed_4(arg1, arg2, arg3, arg4) -> void:
	if is_instance_valid(_object):
		_object.disconnect(_signal_name, _on_completed_4)
		_object = null

	if is_pending:
		complete_release([arg1, arg2, arg3, arg4])

func _on_completed_5(arg1, arg2, arg3, arg4, arg5) -> void:
	if is_instance_valid(_object):
		_object.disconnect(_signal_name, _on_completed_5)
		_object = null

	if is_pending:
		complete_release([arg1, arg2, arg3, arg4, arg5])
