extends Control

class _TestCase:

	signal signal_0
	signal signal_1(arg1)
	signal signal_2(arg1, arg2)
	signal signal_3(arg1, arg2, arg3)
	signal signal_4(arg1, arg2, arg3, arg4)
	signal signal_5(arg1, arg2, arg3, arg4, arg5)

	var _tree: SceneTree
	var _name: String
	var _test_index := 0
	var _pass := 0
	var _fail_logs := []

	func _init(tree: SceneTree, name: String) -> void:
		_tree = tree
		_name = name

	func _report() -> void:
		var text := _name + "\n"
		text += "\tpass "
		text += str(_pass)
		text += " / "
		text += str(_pass + len(_fail_logs))
		if len(_fail_logs) == 0:
			print(text)
			return

		text += "\n\tfail "
		text += str(len(_fail_logs))
		text += "\n"

		for log in _fail_logs:
			text += "\t\t"
			text += log
			text += "\n"

		printerr(text)

#	func run(f: Callable):
#		# おまじない
#		var thunk := func():
#			@warning_ignore(redundant_await)
#			await f.call(_assert)
#			if 0 < len(_fail_indices):
#				printerr(_name)
#			else:
#				print(_name)
#			print("  pass %d" % _pass)
#			if 0 < len(_fail_indices):
#				print("  fail %d <<< %s" % [len(_fail_indices), str(_fail_indices)])
#			unreference()
#		reference()
#		thunk.call()

	func expect(expect_value, actual_value, marker = null):
		if expect_value == actual_value:
			_pass += 1
		elif marker is String:
			_fail_logs.append("[#%d: %s] Expected %s, Actual %s" % [_test_index, marker, str(expect_value), str(actual_value)])
		else:
			_fail_logs.append("[#%d] Expected %s, Actual %s" % [_test_index, str(expect_value), str(actual_value)])
		_test_index += 1
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

	class _Timer:

		var _test_case
		var _expect_delta: float
		var _start_ticks

		func _init(test_case: _TestCase, expect_delta: float) -> void:
			_test_case = test_case
			_expect_delta = expect_delta
			_start_ticks = Time.get_ticks_msec()

		func stop(epsilon := 0.05, marker = null) -> void:
			var delta: float = (Time.get_ticks_msec() - _start_ticks) / 1000.0 - _expect_delta
			if marker is String:
				_test_case.is_true(abs(delta) <= epsilon, marker)
			else:
				_test_case.is_true(abs(delta) <= epsilon, "誤差 |%.3f|s が許容範囲 %.3fs を上回った" % [delta - _expect_delta, epsilon])

	func timer(expect_delta: float):
		return _Timer.new(self, expect_delta)

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

@onready var _tree := get_tree()

func case(name: String, case: Callable) -> void:
	var test_case := _TestCase.new(_tree, name)
	@warning_ignore(redundant_await)
	await case.call(test_case)
	test_case._report()

func _ready():

	case("Async.completed()", func(test):
		# 結果なし
		var a1 := Async.completed()
		test.is_true(a1.is_completed)
		test.is_false(a1.is_canceled)
		test.is_null(await a1.wait())

		# 結果あり
		var a2 := Async.completed(1234)
		test.is_true(a2.is_completed)
		test.is_false(a2.is_canceled)
		test.expect(1234, await a2.wait())
	)

	case("Async.canceled()", func(test):
		var a1 := Async.canceled()
		test.is_false(a1.is_completed)
		test.is_true(a1.is_canceled)
		test.is_null(await a1.wait())
	)

	case("Async.from()", func(test):
		# 待機が生じないパターン #1
		var a1 := Async.from(func(): return)
		test.is_true(a1.is_completed, "awaitable ではないコルーチンに対して待機が発生している")
		test.is_null(await a1.wait())

		# 待機が生じないパターン #2
		var a2 := Async.from(func(): return 1234)
		test.is_true(a2.is_completed, "awaitable ではないコルーチンに対して待機が発生している")
		test.expect(1234, await a2.wait())

		# 待機しなくてはならないパターン #1
		var a3 := Async.from(func(): await test.delay(0.2))
		test.is_false(a3.is_completed, "awaitable であるコルーチンに対して待機が発生している")
		test.is_null(await a3.wait())
		test.is_true(a3.is_completed)

		# 待機しなくてはならないパターン #2
		var a4 := Async.from(func(): await test.delay(0.2); return 1234)
		test.is_false(a4.is_completed, "awaitable であるコルーチンに対して待機が発生している")
		test.expect(1234, await a4.wait())
		test.is_true(a4.is_completed)

		var a5 := Async.from(func(): await test.delay(0.2))
		test.is_false(a5.is_completed, "awaitable であるコルーチンに対して待機が発生していない可能性があります")
		test.is_null(await a5.wait(test.delay_cancel(0.1)))
		test.is_true(a5.is_canceled)

		var a6 := Async.from(func(): await test.delay(0.2); return 1234)
		test.is_false(a6.is_completed, "awaitable であるコルーチンに対して待機が発生していない可能性があります")
		test.is_null(await a6.wait(test.delay_cancel(0.1)))
		test.is_true(a6.is_canceled)
	)

	case("Async.from_signal()", func(test):
		#
		# キャンセルなし
		#

		var a1 := Async.from_signal(test.signal_0)
		test.is_false(a1.is_completed)
		test.delay_emit_0(0.1)
		test.expect([], await a1.wait())
		test.is_true(a1.is_completed)

		var a2 := Async.from_signal(test.signal_1, 1)
		test.is_false(a2.is_completed)
		test.delay_emit_1(0.1, 1234)
		test.expect([1234], await a2.wait())
		test.is_true(a2.is_completed)

		var a3 := Async.from_signal(test.signal_2, 2)
		test.is_false(a3.is_completed)
		test.delay_emit_2(0.1, 1234, "abcd")
		test.expect([1234, "abcd"], await a3.wait())
		test.is_true(a3.is_completed)

		var a4 := Async.from_signal(test.signal_3, 3)
		test.is_false(a4.is_completed)
		test.delay_emit_3(0.1, 1234, "abcd", true)
		test.expect([1234, "abcd", true], await a4.wait())
		test.is_true(a4.is_completed)

		var a5 := Async.from_signal(test.signal_4, 4)
		test.is_false(a5.is_completed)
		test.delay_emit_4(0.1, 1234, "abcd", true, null)
		test.expect([1234, "abcd", true, null], await a5.wait())
		test.is_true(a5.is_completed)

		var a6 := Async.from_signal(test.signal_5, 5)
		test.is_false(a6.is_completed)
		test.delay_emit_5(0.1, 1234, "abcd", true, null, 0.5)
		test.expect([1234, "abcd", true, null, 0.5], await a6.wait())
		test.is_true(a6.is_completed)

		#
		# キャンセルあり
		#

		var a7 := Async.from_signal(test.signal_0)
		test.is_false(a7.is_completed)
		test.delay_emit_0(0.2)
		test.is_null(await a7.wait(test.delay_cancel(0.1)))
		test.is_true(a7.is_canceled)

		var a8 := Async.from_signal(test.signal_1, 1)
		test.is_false(a8.is_completed)
		test.delay_emit_1(0.2, 1234)
		test.is_null(await a8.wait(test.delay_cancel(0.1)))
		test.is_true(a8.is_canceled)

		var a9 := Async.from_signal(test.signal_2, 2)
		test.is_false(a9.is_completed)
		test.delay_emit_2(0.2, 1234, "abcd")
		test.is_null(await a9.wait(test.delay_cancel(0.1)))
		test.is_true(a9.is_canceled)

		var a10 := Async.from_signal(test.signal_3, 3)
		test.is_false(a10.is_completed)
		test.delay_emit_3(0.2, 1234, "abcd", true)
		test.is_null(await a10.wait(test.delay_cancel(0.1)))
		test.is_true(a10.is_canceled)

		var a11 := Async.from_signal(test.signal_4, 4)
		test.is_false(a11.is_completed)
		test.delay_emit_4(0.2, 1234, "abcd", true, null)
		test.is_null(await a11.wait(test.delay_cancel(0.1)))
		test.is_true(a11.is_canceled)

		var a12 := Async.from_signal(test.signal_5, 5)
		test.is_false(a12.is_completed)
		test.delay_emit_5(0.2, 1234, "abcd", true, null, 0.5)
		test.is_null(await a12.wait(test.delay_cancel(0.1)))
		test.is_true(a12.is_canceled)
	)

	case("Async.from_signal_name()", func(test):
		#
		# キャンセルなし
		#

		var a1 := Async.from_signal_name(test, "signal_0")
		test.is_false(a1.is_completed)
		test.delay_emit_0(0.1)
		test.expect([], await a1.wait())
		test.is_true(a1.is_completed)

		var a2 := Async.from_signal_name(test, "signal_1", 1)
		test.is_false(a2.is_completed)
		test.delay_emit_1(0.1, 1234)
		test.expect([1234], await a2.wait())
		test.is_true(a2.is_completed)

		var a3 := Async.from_signal_name(test, "signal_2", 2)
		test.is_false(a3.is_completed)
		test.delay_emit_2(0.1, 1234, "abcd")
		test.expect([1234, "abcd"], await a3.wait())
		test.is_true(a3.is_completed)

		var a4 := Async.from_signal_name(test, "signal_3", 3)
		test.is_false(a4.is_completed)
		test.delay_emit_3(0.1, 1234, "abcd", true)
		test.expect([1234, "abcd", true], await a4.wait())
		test.is_true(a4.is_completed)

		var a5 := Async.from_signal_name(test, "signal_4", 4)
		test.is_false(a5.is_completed)
		test.delay_emit_4(0.1, 1234, "abcd", true, null)
		test.expect([1234, "abcd", true, null], await a5.wait())
		test.is_true(a5.is_completed)

		var a6 := Async.from_signal_name(test, "signal_5", 5)
		test.is_false(a6.is_completed)
		test.delay_emit_5(0.1, 1234, "abcd", true, null, 0.5)
		test.expect([1234, "abcd", true, null, 0.5], await a6.wait())
		test.is_true(a6.is_completed)

		#
		# キャンセルあり
		#

		var a7 := Async.from_signal_name(test, "signal_0")
		test.is_false(a7.is_completed)
		test.delay_emit_0(0.2)
		test.is_null(await a7.wait(test.delay_cancel(0.1)))
		test.is_true(a7.is_canceled)

		var a8 := Async.from_signal_name(test, "signal_1", 1)
		test.is_false(a8.is_completed)
		test.delay_emit_1(0.2, 1234)
		test.is_null(await a8.wait(test.delay_cancel(0.1)))
		test.is_true(a8.is_canceled)

		var a9 := Async.from_signal_name(test, "signal_2", 2)
		test.is_false(a9.is_completed)
		test.delay_emit_2(0.2, 1234, "abcd")
		test.is_null(await a9.wait(test.delay_cancel(0.1)))
		test.is_true(a9.is_canceled)

		var a10 := Async.from_signal_name(test, "signal_3", 3)
		test.is_false(a10.is_completed)
		test.delay_emit_3(0.2, 1234, "abcd", true)
		test.is_null(await a10.wait(test.delay_cancel(0.1)))
		test.is_true(a10.is_canceled)

		var a11 := Async.from_signal_name(test, "signal_4", 4)
		test.is_false(a11.is_completed)
		test.delay_emit_4(0.2, 1234, "abcd", true, null)
		test.is_null(await a11.wait(test.delay_cancel(0.1)))
		test.is_true(a11.is_canceled)

		var a12 := Async.from_signal_name(test, "signal_5", 5)
		test.is_false(a12.is_completed)
		test.delay_emit_5(0.2, 1234, "abcd", true, null, 0.5)
		test.is_null(await a12.wait(test.delay_cancel(0.1)))
		test.is_true(a12.is_canceled)
	)

	case("Async.delay()", func(test):
		var t1 = test.timer(0.2)
		var a1 := Async.delay(0.2)
		test.is_false(a1.is_completed)
		test.expect(0.2, await a1.wait())
		t1.stop()

		var t2 = test.timer(0.1)
		var a2 := Async.delay(0.2)
		test.is_false(a2.is_completed)
		test.is_null(await a2.wait(test.delay_cancel(0.1)))
		test.is_true(a2.is_canceled)
		t2.stop()
	)

	case("Async.delay_msec()", func(test):
		var t1 = test.timer(0.2)
		var a1 := Async.delay_msec(200.0)
		test.is_false(a1.is_completed)
		test.expect(0.2, await a1.wait())
		t1.stop()
	)

	case("Async.delay_usec()", func(test):
		var t1 = test.timer(0.2)
		var a1 := Async.delay_usec(200000.0)
		test.is_false(a1.is_completed)
		test.expect(0.2, await a1.wait())
		t1.stop()
	)

	case("Async.all()", func(test):
		var a1 := Async.all([])
		test.is_true(a1.is_completed)
		test.expect([], await a1.wait())

		var a2 := Async.all([
			"aaaa",
			true,
			0.5,
		])
		test.is_true(a2.is_completed)
		test.expect(["aaaa", true, 0.5], await a2.wait())

		var a3 := Async.all([
			Async.completed("aaaa"),
			Async.completed(true),
			Async.completed(0.5),
		])
		test.is_true(a3.is_completed)
		test.expect(["aaaa", true, 0.5], await a3.wait())

		var a4 := Async.all([
			Async.completed("aaaa"),
			true,
			Async.completed(0.5),
		])
		test.is_true(a4.is_completed)
		test.expect(["aaaa", true, 0.5], await a4.wait())

		var a5 := Async.all([
			Async.canceled(),
			Async.canceled(),
			Async.canceled(),
		])
		test.is_true(a5.is_canceled)
		test.is_null(await a5.wait())

		var a6 := Async.all([
			Async.completed("aaaa"),
			true,
			Async.canceled(),
		])
		test.is_true(a6.is_canceled)
		test.is_null(await a6.wait())

		var c7 := Cancel.new()
		c7.request()
		var a7 := Async.all([
			Async.delay(1.0),
			Async.delay(1.0),
			Async.delay(1.0),
		], c7)
		test.is_true(a7.is_canceled)
		test.is_null(await a7.wait())

		var a8 := Async.all([
			Async.delay(0.125),
			Async.delay(0.25),
			Async.delay(0.5),
		])
		test.is_false(a8.is_completed)
		test.expect([0.125, 0.25, 0.5], await a8.wait())

		var a9 := Async.all([
			Async.delay(0.125),
			0.25,
			Async.completed(0.5),
		])
		test.is_false(a9.is_completed)
		test.expect([0.125, 0.25, 0.5], await a9.wait())

		var a10 := Async.all([
			Async.delay(1.0),
			2.0,
			Async.completed(3.0),
		], test.delay_cancel(0.5))
		test.is_false(a10.is_completed)
		test.is_null(await a10.wait())
		test.is_true(a10.is_canceled)

		var a11 := Async.all([
			Async.delay(1.0),
			1.0,
			Async.completed(1.0),
		])
		test.is_false(a11.is_completed)
		test.is_null(await a11.wait(test.delay_cancel(0.5)))
		test.is_true(a11.is_canceled)

		var c12 = test.delay_cancel(0.5)
		var a12 := Async.all([
			Async.delay(1.0),
			1.0,
			Async.completed(1.0),
		], c12)
		test.is_false(a12.is_completed)
		test.is_null(await a12.wait(c12))
		test.is_true(a12.is_canceled)

		var a13 := Async.all([
			Async.completed(1.0),
			Async.completed(1.0),
			Async.canceled(),
		])
		test.is_false(a13.is_completed)
		test.is_true(a13.is_canceled)
	)

	case("Async.all_settled()", func(test):
		var a1 := Async.all_settled([])
		test.is_true(a1.is_completed)
		var a1_r = test.is_not_null(await a1.wait())
		test.expect([], a1_r)

		var a2 := Async.all_settled([
			"aaaa",
			true,
			0.5,
		])
		test.is_true(a2.is_completed)
		var a2_r = test.is_not_null(await a2.wait())
		test.expect("aaaa", await a2_r[0].wait())
		test.expect(true, await a2_r[1].wait())
		test.expect(0.5, await a2_r[2].wait())

		var a3 := Async.all_settled([
			Async.completed("aaaa"),
			Async.completed(true),
			Async.completed(0.5),
		])
		test.is_true(a3.is_completed)
		var a3_r = test.is_not_null(await a3.wait())
		test.expect("aaaa", await a3_r[0].wait())
		test.expect(true, await a3_r[1].wait())
		test.expect(0.5, await a3_r[2].wait())

		var a4 := Async.all_settled([
			Async.completed("aaaa"),
			true,
			Async.completed(0.5),
		])
		test.is_true(a4.is_completed)
		var a4_r = test.is_not_null(await a4.wait())
		test.expect("aaaa", await a4_r[0].wait())
		test.expect(true, await a4_r[1].wait())
		test.expect(0.5, await a4_r[2].wait())

		var a5 := Async.all_settled([
			Async.canceled(),
			Async.canceled(),
			Async.canceled(),
		])
		test.is_true(a5.is_completed)
		var a5_r = test.is_not_null(await a5.wait())
		test.is_true(a5_r[0].is_canceled)
		test.is_true(a5_r[0].is_canceled)
		test.is_true(a5_r[0].is_canceled)

		var a6 := Async.all_settled([
			Async.completed("aaaa"),
			true,
			Async.canceled(),
		])
		test.is_true(a6.is_completed)
		var a6_r = test.is_not_null(await a6.wait())
		test.expect("aaaa", await a6_r[0].wait())
		test.expect(true, await a6_r[1].wait())
		test.is_true(a6_r[2].is_canceled)

		var c7 := Cancel.new()
		c7.request()
		var a7 := Async.all_settled([
			Async.delay(1.0),
			Async.delay(2.0),
			Async.delay(3.0),
		], c7)
		test.is_true(a7.is_completed)
		var a7_r = test.is_not_null(await a7.wait())
		test.is_true(a7_r[0].is_canceled)
		test.is_true(a7_r[1].is_canceled)
		test.is_true(a7_r[2].is_canceled)

		var a8 := Async.all_settled([
			Async.delay(0.125),
			Async.delay(0.25),
			Async.delay(0.5),
		])
		test.is_false(a8.is_completed)
		var a8_r = test.is_not_null(await a8.wait())
		test.expect(0.125, await a8_r[0].wait())
		test.expect(0.25, await a8_r[1].wait())
		test.expect(0.5, await a8_r[2].wait())

		var a9 := Async.all_settled([
			Async.delay(0.125),
			0.25,
			Async.completed(0.5),
		])
		test.is_false(a9.is_completed)
		var a9_r = test.is_not_null(await a9.wait())
		test.expect(0.125, await a9_r[0].wait())
		test.expect(0.25, await a9_r[1].wait())
		test.expect(0.5, await a9_r[2].wait())

		var a10 := Async.all_settled([
			Async.delay(1.0),
			2.0,
			Async.completed(3.0),
		], test.delay_cancel(0.5))
		test.is_false(a10.is_completed)
		var a10_r = test.is_not_null(await a10.wait())
		test.is_true(a10_r[0].is_canceled)
		test.is_true(a10_r[1].is_completed)
		test.is_true(a10_r[2].is_completed)

		var a11 := Async.all_settled([
			Async.delay(1.0),
			1.0,
			Async.completed(1.0),
		])
		test.is_false(a11.is_completed)
		test.is_null(await a11.wait(test.delay_cancel(0.5)))
		test.is_true(a11.is_canceled)

		var c12 = test.delay_cancel(0.5)
		var a12 := Async.all_settled([
			Async.delay(1.0),
			1.0,
			Async.completed(1.0),
		], c12)
		test.is_false(a12.is_completed)
		var a12_r = test.is_not_null(await a12.wait(c12))
		test.is_true(a12_r[0].is_canceled)
		test.expect(1.0, await a12_r[1].wait())
		test.expect(1.0, await a12_r[2].wait())
	)

	case("Async.any()", func(test):
		var a1 := Async.any([])
		test.is_true(a1.is_canceled)
		test.is_null(await a1.wait())

		var a2 := Async.any([
			"aaaa",
			true,
			0.5,
		])
		test.is_true(a2.is_completed)
		test.expect("aaaa", await a2.wait())

		var a3 := Async.any([
			Async.completed("aaaa"),
			Async.completed(true),
			Async.completed(0.5),
		])
		test.is_true(a3.is_completed)
		test.expect("aaaa", await a3.wait())

		var a4 := Async.any([
			Async.completed("aaaa"),
			true,
			Async.completed(0.5),
		])
		test.is_true(a4.is_completed)
		test.expect("aaaa", await a4.wait())

		var a5 := Async.any([
			Async.canceled(),
			Async.canceled(),
			Async.canceled(),
		])
		test.is_true(a5.is_canceled)
		test.is_null(await a5.wait())

		var a6 := Async.any([
			Async.completed("aaaa"),
			true,
			Async.canceled(),
		])
		test.is_true(a6.is_completed)
		test.expect("aaaa", await a6.wait())

		var a7 := Async.any([
			Async.delay(1.0),
			Async.delay(1.0),
			Async.delay(1.0),
		], test.delay_cancel(0.5))
		test.is_false(a7.is_completed)
		test.is_null(await a7.wait())

		var a8 := Async.any([
			Async.delay(0.125),
			Async.delay(0.25),
			Async.delay(0.5),
		])
		test.is_false(a8.is_completed)
		test.expect(0.125, await a8.wait())

		var a9 := Async.any([
			Async.delay(0.125),
			0.25,
			Async.completed(0.5),
		])
		test.is_true(a9.is_completed)
		test.expect(0.25, await a9.wait())

		var a10 := Async.any([
			Async.delay(1.0),
			2.0,
			Async.completed(3.0),
		], test.delay_cancel(0.5))
		test.is_true(a10.is_completed)
		test.expect(2.0, await a10.wait())

		var a11 := Async.any([
			Async.delay(1.0),
			1.0,
			Async.completed(1.0),
		])
		test.is_true(a11.is_completed)
		test.expect(1.0, await a11.wait(test.delay_cancel(0.5)))

		var c12 = test.delay_cancel(0.5)
		var a12 := Async.any([
			Async.delay(1.0),
			1.0,
			Async.completed(1.0),
		], c12)
		test.is_true(a12.is_completed)
		test.expect(1.0, await a12.wait(c12))

		var a13 := Async.any([
			Async.completed(1.0),
			Async.completed(1.0),
			Async.canceled(),
		])
		test.is_true(a13.is_completed)
		test.expect(1.0, await a13.wait())
	)

	case("Async.race()", func(test):
#		var a1 := Async.race([])
#		test.is_true(a1.is_completed)
#		test.is_null(await a1.wait())

		var a2 := Async.race([
			"aaaa",
			true,
			0.5,
		])
		test.is_true(a2.is_completed)
		var a2_r = test.is_not_null(await a2.wait())
		test.expect("aaaa", await a2_r.wait())

		var a3 := Async.race([
			Async.completed("aaaa"),
			Async.completed(true),
			Async.completed(0.5),
		])
		test.is_true(a3.is_completed)
		var a3_r = test.is_not_null(await a3.wait())
		test.expect("aaaa", await a3_r.wait())

		var a4 := Async.race([
			Async.completed("aaaa"),
			true,
			Async.completed(0.5),
		])
		test.is_true(a4.is_completed)
		var a4_r = test.is_not_null(await a4.wait())
		test.expect("aaaa", await a4_r.wait())

		var a5 := Async.race([
			Async.canceled(),
			Async.canceled(),
			Async.canceled(),
		])
		test.is_true(a5.is_canceled)
		test.is_null(await a5.wait())

		var a6 := Async.race([
			Async.completed("aaaa"),
			true,
			Async.canceled(),
		])
		test.is_true(a6.is_completed)
		var a6_r = test.is_not_null(await a6.wait())
		test.expect("aaaa", await a6_r.wait())

		var c7 := Cancel.new()
		c7.request()
		var a7 := Async.race([
			Async.delay(1.0),
			Async.delay(2.0),
			Async.delay(3.0),
		], c7)
		test.is_true(a7.is_canceled)
		test.is_null(await a7.wait())

		var a8 := Async.race([
			Async.delay(0.125),
			Async.delay(0.25),
			Async.delay(0.5),
		])
		test.is_false(a8.is_completed)
		var a8_r = test.is_not_null(await a8.wait())
		test.expect(0.125, await a8_r.wait())

		var a9 := Async.race([
			Async.delay(0.125),
			0.25,
			Async.completed(0.5),
		])
		test.is_true(a9.is_completed)
		var a9_r = test.is_not_null(await a9.wait())
		test.expect(0.25, await a9_r.wait())

		var a10 := Async.race([
			Async.delay(1.0),
			2.0,
			Async.completed(3.0),
		], test.delay_cancel(0.5))
		test.is_true(a10.is_completed)
		var a10_r = test.is_not_null(await a10.wait())
		test.expect(2.0, await a10_r.wait())

		var a11 := Async.race([
			Async.delay(1.0),
			1.0,
			Async.completed(1.0),
		])
		test.is_true(a11.is_completed)
		var a11_r = test.is_not_null(await a11.wait(test.delay_cancel(0.5)))
		test.expect(1.0, await a11_r.wait())

		var c12 = test.delay_cancel(0.5)
		var a12 := Async.race([
			Async.delay(1.0),
			1.0,
			Async.completed(1.0),
		], c12)
		test.is_true(a12.is_completed)
		var a12_r = test.is_not_null(await a12.wait(c12))
		test.expect(1.0, await a12_r.wait())
	)

	case("Async.then()", func(test):
		var a1 := Async.completed(10).then(func(result): return result * result)
		test.is_true(a1.is_completed)
		test.expect(100, await a1.wait())

		var a2 := Async.canceled().then(func(result): return result * result)
		test.is_true(a2.is_canceled)
		test.is_null(await a2.wait())

		var a3 := Async.delay(0.125).then(func(result): return result * 2.0)
		test.is_false(a3.is_completed)
		test.expect(0.25, await a3.wait())

		var a4 := Async.completed(10).then(func(result):
			await Async.wait_delay(0.125)
			return result * result
		)
		test.is_false(a4.is_completed)
		test.expect(100, await a4.wait())

		var a5 := Async.delay(0.25).then(func(result): return result * 2.0, test.delay_cancel(0.125))
		test.is_false(a5.is_completed)
		test.is_false(a5.is_canceled)
		test.is_null(await a5.wait())
		test.is_true(a5.is_canceled)

		var a6 := Async.delay(0.25).then(func(result): return result * 2.0)
		test.is_false(a6.is_completed)
		test.is_false(a6.is_canceled)
		test.is_null(await a6.wait(test.delay_cancel(0.125)))
		test.is_true(a6.is_canceled)

		var c7 = test.delay_cancel(0.125)
		var a7 := Async.delay(0.25).then(func(result): return result * 2.0, c7)
		test.is_false(a7.is_completed)
		test.is_false(a7.is_canceled)
		test.is_null(await a7.wait(c7))
		test.is_true(a7.is_canceled)

		var c8 := Cancel.new()
		c8.request()
		var a8 := Async.delay(0.25).then(func(result): return result * 2.0, c8)
		test.is_false(a8.is_completed)
		test.is_true(a8.is_canceled)
		test.is_null(await a8.wait(c8))
	)

	case("Async.unwrap()", func(test):
		var a1 := Async.completed(10).unwrap()
		test.is_true(a1.is_completed)
		test.expect(10, await a1.wait())

		var a2 := Async.completed(Async.completed(10)).unwrap()
		test.is_true(a2.is_completed)
		test.expect(10, await a2.wait())

		var a3 := Async.completed(Async.completed(Async.completed(10))).unwrap(2)
		test.is_true(a3.is_completed)
		test.expect(10, await a3.wait())

		var a4 := Async.canceled().unwrap()
		test.is_true(a4.is_canceled)
		test.is_null(await a4.wait())

		var a5 := Async.completed(Async.delay(0.25)).unwrap()
		test.is_false(a5.is_completed)
		test.expect(0.25, await a5.wait())

		var a6 := Async.completed(Async.delay(0.25)).unwrap(1, test.delay_cancel(0.125))
		test.is_false(a6.is_completed)
		test.is_false(a6.is_canceled)
		test.is_null(await a6.wait())
		test.is_true(a6.is_canceled)

		var a7 := Async.completed(Async.completed(Async.delay(0.25))).unwrap(1, test.delay_cancel(0.125))
		test.is_true(a7.is_completed)
		var a7_r = test.is_not_null(await a7.wait())
		test.is_false(a7_r.is_completed)
		test.expect(0.25, await a7_r.wait())
	)
