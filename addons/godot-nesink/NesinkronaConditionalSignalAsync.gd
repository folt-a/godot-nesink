class_name NesinkronaFromConditionalSignalAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------
# 定数
#---------------------------------------------------------------------------------------------------

const MAX_SIGNAL_ARGC := 5

#---------------------------------------------------------------------------------------------------

var _object: Object
var _signal: Signal
var _signal_args: Array

static func _match(a: Variant, b: Variant) -> bool:
	return a is Object and a == SKIP or a == b

func _init(signal_: Signal, signal_args: Array) -> void:
	assert(signal_args.size() <= MAX_SIGNAL_ARGC)

	_object = signal_.get_object()
	_signal = signal_
	_signal_args = signal_args

	assert(is_instance_valid(_object) or not signal_.is_null())

	match len(_signal_args):
		0: signal_.connect(_on_completed_0)
		1: signal_.connect(_on_completed_1)
		2: signal_.connect(_on_completed_2)
		3: signal_.connect(_on_completed_3)
		4: signal_.connect(_on_completed_4)
		5: signal_.connect(_on_completed_5)

func _on_completed_0() -> void:
	if is_pending:
		if is_instance_valid(_object) and _signal.is_connected(_on_completed_0):
			_signal.disconnect(_on_completed_0)
		complete_release([])
	_object = null

func _on_completed_1(arg1: Variant) -> void:
	if is_pending:
		if (not _match(_signal_args[0], arg1)):
			return
		if is_instance_valid(_object) and _signal.is_connected(_on_completed_1):
			_signal.disconnect(_on_completed_1)
		complete_release([arg1])
	_object = null

func _on_completed_2(arg1: Variant, arg2: Variant) -> void:
	if is_pending:
		if (not _match(_signal_args[0], arg1) or
			not _match(_signal_args[1], arg2)):
			return
		if is_instance_valid(_object) and _signal.is_connected(_on_completed_2):
			_signal.disconnect(_on_completed_2)
		complete_release([arg1, arg2])
	_object = null

func _on_completed_3(arg1: Variant, arg2: Variant, arg3: Variant) -> void:
	if is_pending:
		if (not _match(_signal_args[0], arg1) or
			not _match(_signal_args[1], arg2) or
			not _match(_signal_args[2], arg3)):
			return
		if is_instance_valid(_object) and _signal.is_connected(_on_completed_3):
			_signal.disconnect(_on_completed_3)
		complete_release([arg1, arg2, arg3])
	_object = null

func _on_completed_4(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant) -> void:
	if is_pending:
		if (not _match(_signal_args[0], arg1) or
			not _match(_signal_args[1], arg2) or
			not _match(_signal_args[2], arg3) or
			not _match(_signal_args[3], arg4)):
			return
		if is_instance_valid(_object) and _signal.is_connected(_on_completed_4):
			_signal.disconnect(_on_completed_4)
		complete_release([arg1, arg2, arg3, arg4])
	_object = null

func _on_completed_5(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant, arg5: Variant) -> void:
	if is_pending:
		if (not _match(_signal_args[0], arg1) or
			not _match(_signal_args[1], arg2) or
			not _match(_signal_args[2], arg3) or
			not _match(_signal_args[3], arg4) or
			not _match(_signal_args[4], arg5)):
			return
		if is_instance_valid(_object) and _signal.is_connected(_on_completed_5):
			_signal.disconnect(_on_completed_5)
		complete_release([arg1, arg2, arg3, arg4, arg5])
	_object = null
