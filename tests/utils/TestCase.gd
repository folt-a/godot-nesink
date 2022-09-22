class_name TestCase

signal signal_0
signal signal_1(arg1)
signal signal_2(arg1, arg2)
signal signal_3(arg1, arg2, arg3)
signal signal_4(arg1, arg2, arg3, arg4)
signal signal_5(arg1, arg2, arg3, arg4, arg5)

func expect(expect_value, actual_value, marker = null):
	_test_index += 1
	if expect_value == actual_value:
		_pass += 1
	elif marker is String:
		_fail_logs.append("[#%d: %s] Expected %s, Actual %s" % [_test_index, marker, str(expect_value), str(actual_value)])
	else:
		_fail_logs.append("[#%d] Expected %s, Actual %s" % [_test_index, str(expect_value), str(actual_value)])
	return actual_value

func is_true(actual_value: bool, marker = null):
	return expect(true, actual_value, marker)

func is_false(actual_value: bool, marker = null):
	return expect(false, actual_value, marker)

func is_null(actual_value, marker = null):
	return expect(null, actual_value, marker)

func is_not_null(actual_value, marker = null):
	is_true(actual_value != null, marker)
	return actual_value

func timer(expect_delta: float):
	return TestTimer.new(self, expect_delta)

func delay(timeout: float) -> void:
	await _tree.create_timer(timeout).timeout

func delay_cancel(timeout: float) -> Cancel:
	var cancel := Cancel.new()
	_tree.create_timer(timeout).timeout.connect(cancel.request)
	return cancel

func emit_0() -> void:
	signal_0.emit()

func emit_1(arg1) -> void:
	signal_1.emit(arg1)

func emit_2(arg1, arg2) -> void:
	signal_2.emit(arg1, arg2)

func emit_3(arg1, arg2, arg3) -> void:
	signal_3.emit(arg1, arg2, arg3)

func emit_4(arg1, arg2, arg3, arg4) -> void:
	signal_4.emit(arg1, arg2, arg3, arg4)

func emit_5(arg1, arg2, arg3, arg4, arg5) -> void:
	signal_5.emit(arg1, arg2, arg3, arg4, arg5)

func delay_emit_0(timeout: float) -> void:
	_tree.create_timer(timeout).timeout.connect(emit_0)

func delay_emit_1(timeout: float, arg1) -> void:
	_tree.create_timer(timeout).timeout.connect(emit_1.bind(arg1))

func delay_emit_2(timeout: float, arg1, arg2) -> void:
	_tree.create_timer(timeout).timeout.connect(emit_2.bind(arg1, arg2))

func delay_emit_3(timeout: float, arg1, arg2, arg3) -> void:
	_tree.create_timer(timeout).timeout.connect(emit_3.bind(arg1, arg2, arg3))

func delay_emit_4(timeout: float, arg1, arg2, arg3, arg4) -> void:
	_tree.create_timer(timeout).timeout.connect(emit_4.bind(arg1, arg2, arg3, arg4))

func delay_emit_5(timeout: float, arg1, arg2, arg3, arg4, arg5) -> void:
	_tree.create_timer(timeout).timeout.connect(emit_5.bind(arg1, arg2, arg3, arg4, arg5))

func run() -> void:
	@warning_ignore(redundant_await)
	await _test_method.call(self)

	var text := _name + "\n"
	text += "\tpass "
	text += str(_pass)
	text += " / "
	text += str(_pass + len(_fail_logs))
	if len(_fail_logs) == 0:
		print(text)
	else:
		text += "\n\tfail "
		text += str(len(_fail_logs))
		text += "\n"
		for fail_log in _fail_logs:
			text += "\t\t"
			text += fail_log
			text += "\n"
		printerr(text)

var _tree: SceneTree
var _name: String
var _test_index := 0
var _test_method: Callable
var _pass := 0
var _fail_logs := []

func _init(
	tree: SceneTree,
	name_: String,
	test_method: Callable) -> void:

	_tree = tree
	_name = name_
	_test_method = test_method
