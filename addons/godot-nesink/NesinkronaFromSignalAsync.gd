class_name NesinkronaFromSignalAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------
# 定数
#---------------------------------------------------------------------------------------------------

const MAX_SIGNAL_ARGC := 5

#---------------------------------------------------------------------------------------------------

var _object: Object

func _init(signal_: Signal, signal_argc: int) -> void:
	assert(signal_argc <= MAX_SIGNAL_ARGC)

	_object = signal_.get_object()

	if is_instance_valid(_object):
		match signal_argc:
			0: signal_.connect(_on_completed_0, CONNECT_REFERENCE_COUNTED)
			1: signal_.connect(_on_completed_1, CONNECT_REFERENCE_COUNTED)
			2: signal_.connect(_on_completed_2, CONNECT_REFERENCE_COUNTED)
			3: signal_.connect(_on_completed_3, CONNECT_REFERENCE_COUNTED)
			4: signal_.connect(_on_completed_4, CONNECT_REFERENCE_COUNTED)
			5: signal_.connect(_on_completed_5, CONNECT_REFERENCE_COUNTED)
	else:
		assert(not signal_.is_null())
		match signal_argc:
			0: signal_.connect(_on_completed_0)
			1: signal_.connect(_on_completed_1)
			2: signal_.connect(_on_completed_2)
			3: signal_.connect(_on_completed_3)
			4: signal_.connect(_on_completed_4)
			5: signal_.connect(_on_completed_5)

func _on_completed_0() -> void:
	if is_pending:
		complete_release([])
	_object = null

func _on_completed_1(arg1: Variant) -> void:
	if is_pending:
		complete_release([arg1])
	_object = null

func _on_completed_2(arg1: Variant, arg2: Variant) -> void:
	if is_pending:
		complete_release([arg1, arg2])
	_object = null

func _on_completed_3(arg1: Variant, arg2: Variant, arg3: Variant) -> void:
	if is_pending:
		complete_release([arg1, arg2, arg3])
	_object = null

func _on_completed_4(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant) -> void:
	if is_pending:
		complete_release([arg1, arg2, arg3, arg4])
	_object = null

func _on_completed_5(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant, arg5: Variant) -> void:
	if is_pending:
		complete_release([arg1, arg2, arg3, arg4, arg5])
	_object = null
