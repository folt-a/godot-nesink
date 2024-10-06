class_name NesinkronaFromConditionalSignalNameAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------
# 定数
#---------------------------------------------------------------------------------------------------

const MAX_SIGNAL_ARGC := 5

#---------------------------------------------------------------------------------------------------

var _object: Object
var _signal_name: StringName
var _signal_args: Array

static func _match(a: Variant, b: Variant) -> bool:
	return a is Object and a == SKIP or a == b

func _init(object: Object, signal_name: StringName, signal_args: Array) -> void:
	assert(object != null)
	assert(signal_args.size() <= MAX_SIGNAL_ARGC)

	_object = object
	_signal_name = signal_name
	_signal_args = signal_args

	if is_instance_valid(_object):
		match len(_signal_args):
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

func _on_completed_1(arg1: Variant) -> void:
	if (_match(_signal_args[0], arg1)):
		if is_instance_valid(_object):
			_object.disconnect(_signal_name, _on_completed_1)
		_object = null
		if is_pending:
			complete_release([arg1])

func _on_completed_2(arg1: Variant, arg2: Variant) -> void:
	if (_match(_signal_args[0], arg1) and
		_match(_signal_args[1], arg2)):
		if is_instance_valid(_object):
			_object.disconnect(_signal_name, _on_completed_2)
		_object = null
		if is_pending:
			complete_release([arg1, arg2])

func _on_completed_3(arg1: Variant, arg2: Variant, arg3: Variant) -> void:
	if (_match(_signal_args[0], arg1) and
		_match(_signal_args[1], arg2) and
		_match(_signal_args[2], arg3)):
		if is_instance_valid(_object):
			_object.disconnect(_signal_name, _on_completed_3)
		_object = null
		if is_pending:
			complete_release([arg1, arg2, arg3])

func _on_completed_4(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant) -> void:
	if (_match(_signal_args[0], arg1) and
		_match(_signal_args[1], arg2) and
		_match(_signal_args[2], arg3) and
		_match(_signal_args[3], arg4)):
		if is_instance_valid(_object):
			_object.disconnect(_signal_name, _on_completed_4)
		_object = null
		if is_pending:
			complete_release([arg1, arg2, arg3, arg4])

func _on_completed_5(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant, arg5: Variant) -> void:
	if (_match(_signal_args[0], arg1) and
		_match(_signal_args[1], arg2) and
		_match(_signal_args[2], arg3) and
		_match(_signal_args[3], arg4) and
		_match(_signal_args[4], arg5)):
		if is_instance_valid(_object):
			_object.disconnect(_signal_name, _on_completed_5)
		_object = null
		if is_pending:
			complete_release([arg1, arg2, arg3, arg4, arg5])
