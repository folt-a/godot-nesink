class_name NesinkronaFromSignalAsync extends NesinkronaAsyncBase

#---------------------------------------------------------------------------------------------------
# 定数
#---------------------------------------------------------------------------------------------------

const MAX_SIGNAL_ARGC := 5

#---------------------------------------------------------------------------------------------------

var _signal: Signal

func _init(
	signal_: Signal,
	signal_argc: int) -> void:

	assert(signal_argc <= MAX_SIGNAL_ARGC)

	super._init()

	_signal = signal_
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
	_signal.disconnect(_on_completed_0)

func _on_completed_1(arg1) -> void:
	if is_pending:
		complete_release([arg1])
	_signal.disconnect(_on_completed_1)

func _on_completed_2(arg1, arg2) -> void:
	if is_pending:
		complete_release([arg1, arg2])
	_signal.disconnect(_on_completed_2)

func _on_completed_3(arg1, arg2, arg3) -> void:
	if is_pending:
		complete_release([arg1, arg2, arg3])
	_signal.disconnect(_on_completed_3)

func _on_completed_4(arg1, arg2, arg3, arg4) -> void:
	if is_pending:
		complete_release([arg1, arg2, arg3, arg4])
	_signal.disconnect(_on_completed_4)

func _on_completed_5(arg1, arg2, arg3, arg4, arg5) -> void:
	if is_pending:
		complete_release([arg1, arg2, arg3, arg4, arg5])
	_signal.disconnect(_on_completed_5)
