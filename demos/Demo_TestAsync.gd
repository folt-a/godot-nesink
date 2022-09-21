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
		var a1 := Async.completed()
		test.is_true(a1.is_completed)
		test.is_false(a1.is_canceled)
		test.is_null(await a1.wait())

		var a2 := Async.completed(1234)
		test.is_true(a2.is_completed)
		test.is_false(a2.is_canceled)
		test.expect(await a2.wait(), 1234)
	)

	case("Async.canceled()", func(test):
		var a1 := Async.canceled()
		test.is_false(a1.is_completed)
		test.is_true(a1.is_canceled)
		test.is_null(await a1.wait())
	)

	case("Async.from()", func(test):
		var a1 := Async.from(func(): return)
		test.is_true(a1.is_completed, "awaitable ではないコルーチンに対して待機が発生している可能性があります")
		test.is_null(await a1.wait())

		var a2 := Async.from(func(): return 1234)
		test.is_true(a2.is_completed, "awaitable ではないコルーチンに対して待機が発生している可能性があります")
		test.expect(1234, await a2.wait())

		#
		# メモ:
		#
		# 以下 Async.from について、NesinkronaFromAsync コンストラクタ内でコルーチン側へインストラクションを
		# 分岐 (実装内 _init_flight) すると、awaitable である Callable を受け取った場合よくわからない挙動を示す。
		#
		# awaitable な Callable を await するサンク関数を挟み await する、という条件で
		# 必ずこの実行時エラーが発生するようなのでテストランナー側の修正のみにとどめました。
		# これは同様の回避策を実装へ適用してしまうと awaitable でない処理が即座に完了しなくなるためです。
		#

		#@warning_ignore(redundant_await)
		var a3 := Async.from(func(): await test.delay(0.2))
		test.is_false(a3.is_completed, "awaitable であるコルーチンに対して待機が発生していない可能性があります")
		test.is_null(await a3.wait())
		test.is_true(a3.is_completed)

		#@warning_ignore(redundant_await)
		var a4 := Async.from(func(): await test.delay(0.2); return 1234)
		test.is_false(a4.is_completed, "awaitable であるコルーチンに対して待機が発生していない可能性があります")
		test.expect(1234, await a4.wait())
		test.is_true(a4.is_completed)

		#@warning_ignore(redundant_await)
		var a5 := Async.from(func(): await test.delay(0.2))
		test.is_false(a5.is_completed, "awaitable であるコルーチンに対して待機が発生していない可能性があります")
		test.is_null(await a5.wait(test.delay_cancel(0.1)))
		test.is_true(a5.is_canceled)

		#@warning_ignore(redundant_await)
		var a6 := Async.from(func(): await test.delay(0.2); return 1234)
		test.is_false(a6.is_completed, "awaitable であるコルーチンに対して待機が発生していない可能性があります")
		test.is_null(await a6.wait(test.delay_cancel(0.1)))
		test.is_true(a6.is_canceled)
	)

	case("Async.from_signal()", func(test):
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

		var t2 = test.timer(0.1)
		var a2 := Async.delay_msec(200.0)
		test.is_false(a2.is_completed)
		test.is_null(await a2.wait(test.delay_cancel(0.1)))
		test.is_true(a2.is_canceled)
		t2.stop()
	)

	case("Async.delay_usec()", func(test):
		var t1 = test.timer(0.2)
		var a1 := Async.delay_usec(200000.0)
		test.is_false(a1.is_completed)
		test.expect(0.2, await a1.wait())
		t1.stop()

		var t2 = test.timer(0.1)
		var a2 := Async.delay_usec(200000.0)
		test.is_false(a2.is_completed)
		test.is_null(await a2.wait(test.delay_cancel(0.1)))
		test.is_true(a2.is_canceled)
		t2.stop()
	)

	case("Async.all()", func(test):
		var t1 := Async.all([])
		test.is_true(t1.is_completed)
		test.expect([], await t1.wait())

		var t2 := Async.all([
			Async.completed(0.125),
			Async.completed(0.25),
			Async.completed(0.5),
		])
		test.is_true(t2.is_completed)
		test.expect([0.125, 0.25, 0.5], await t2.wait())

		var t3 := Async.all([
			Async.canceled(),
			Async.canceled(),
			Async.canceled(),
		])
		test.is_true(t3.is_canceled)
		test.is_null(await t3.wait())

		var t4 := Async.all([
			Async.delay(0.125),
			Async.delay(0.25),
			Async.completed(0.5),
		])
		test.is_false(t4.is_completed)
		test.expect([0.125, 0.25, 0.5], await t4.wait())

		var t5 := Async.all([
			Async.delay(0.125),
			Async.delay(0.25),
			0.5,
		])
		test.is_false(t5.is_completed)
		test.expect([0.125, 0.25, 0.5], await t5.wait())

		var t6 := Async.all([
			0.125,
			0.25,
			0.5,
		])
		test.is_true(t6.is_completed)
		test.expect([0.125, 0.25, 0.5], await t6.wait())

		var t7 := Async.all([
			Async.delay(1.0),
			2.0,
			Async.completed(1.0),
		], test.delay_cancel(0.5)) # ドレインを途中でキャンセル
		test.is_false(t7.is_completed)
		test.is_null(await t7.wait())
		test.is_true(t7.is_canceled)

		var t8 := Async.all([
			Async.delay(1.0),
			2.0,
			Async.completed(3.0),
		])
		test.is_false(t8.is_completed)
		test.is_null(await t8.wait(test.delay_cancel(0.5))) # 待機を途中でキャンセル
		test.is_true(t8.is_canceled)

		var c9 = test.delay_cancel(0.5) # ドレインと待機を途中でキャンセル
		var t9 := Async.all([
			Async.delay(1.0),
			2.0,
			Async.completed(3.0),
		], c9)
		test.is_false(t9.is_completed)
		test.is_null(await t9.wait(c9))
		test.is_true(t9.is_canceled)

		var t10 := Async.all([
			Async.completed(1.0),
			Async.completed(2.0),
			Async.canceled(),
		])
		test.is_false(t10.is_completed)
		test.is_true(t10.is_canceled)
	)

	case("Async.all_settled()", func(test):
		# 空
		var t1 := Async.all_settled([])
		test.is_true(t1.is_completed)
		var t1_r = test.is_not_null(await t1.wait())
		test.expect([], t1_r)

		# すべてが値
		var t2 := Async.all_settled([1.0, 2.0, 3.0])
		test.is_true(t1.is_completed)
		var t2_r = test.is_not_null(await t2.wait())
		test.expect(1.0, await t2_r[0].wait())
		test.expect(2.0, await t2_r[1].wait())
		test.expect(3.0, await t2_r[2].wait())

		# すべてが完了済みの Async
		var t3 := Async.all_settled([
			Async.completed(1.0),
			Async.completed(2.0),
			Async.completed(3.0),
		])
		test.is_true(t3.is_completed)
		var t3_r = test.is_not_null(await t3.wait())
		test.expect(1.0, await t3_r[0].wait())
		test.expect(2.0, await t3_r[1].wait())
		test.expect(3.0, await t3_r[2].wait())

		# すべてが Async
		var t4 := Async.all_settled([
			Async.delay(1.0),
			Async.completed(2.0),
			Async.completed(3.0),
		])
		test.is_false(t4.is_completed)
		var t4_r = test.is_not_null(await t4.wait())
		test.expect(1.0, await t4_r[0].wait())
		test.expect(2.0, await t4_r[1].wait())
		test.expect(3.0, await t4_r[2].wait())

		# すべてが完了済みの Async と値
		var t5 := Async.all_settled([
			Async.completed(1.0),
			2.0,
			Async.completed(3.0),
		])
		test.is_true(t5.is_completed)
		var t5_r = test.is_not_null(await t5.wait())
		test.expect(1.0, await t5_r[0].wait())
		test.expect(2.0, await t5_r[1].wait())
		test.expect(3.0, await t5_r[2].wait())

		# すべてが Async と値
		var t6 := Async.all_settled([
			Async.delay(1.0),
			2.0,
			Async.completed(3.0),
		])
		test.is_false(t6.is_completed)
		var t6_r = test.is_not_null(await t6.wait())
		test.expect(1.0, await t6_r[0].wait())
		test.expect(2.0, await t6_r[1].wait())
		test.expect(3.0, await t6_r[2].wait())

		# ドレインを途中でキャンセル
		var t7 := Async.all_settled([
			Async.delay(1.0),
			2.0,
			Async.completed(3.0),
		], test.delay_cancel(0.5))
		test.is_false(t7.is_completed)
		var t7_r = test.is_not_null(await t7.wait())
		test.is_null(await t7_r[0].wait())
		test.expect(2.0, await t7_r[1].wait())
		test.expect(3.0, await t7_r[2].wait())

		# 待機を途中でキャンセル
		var t8 := Async.all_settled([
			Async.delay(1.0),
			2.0,
			Async.completed(3.0),
		])
		test.is_false(t8.is_completed)
		test.is_null(await t8.wait(test.delay_cancel(0.5)))
		test.is_true(t8.is_canceled)

		# ドレインと待機を途中でキャンセル
		var c9 = test.delay_cancel(0.5)
		var t9 := Async.all_settled([
			Async.delay(1.0),
			2.0,
			Async.completed(3.0),
		], c9)
		# 同一キャンセルを使った場合、ドレイン wait() を優先したいため以下であってる
		# ドレインキャンセル後 t9.wait() 待機側へシグナルし再開している
		test.is_false(t9.is_completed)
		var t9_r = test.is_not_null(await t9.wait())
		test.is_null(await t9_r[0].wait())
		test.expect(2.0, await t9_r[1].wait())
		test.expect(3.0, await t9_r[2].wait())
		test.is_true(t9.is_completed)

		# キャンセルされた Async を含む
		var t10 := Async.all_settled([
			Async.completed(1.0),
			Async.completed(2.0),
			Async.canceled(),
		])
		test.is_true(t10.is_completed)
		test.is_false(t10.is_canceled)
		var t10_r = test.is_not_null(await t10.wait())
		test.expect(1.0, await t10_r[0].wait())
		test.expect(2.0, await t10_r[1].wait())
		test.is_null(await t10_r[2].wait())
		test.is_true(t9.is_completed)
	)

	case("Async.any()", func(test):
		var t1 := Async.any([])
		test.is_true(t1.is_canceled)
		test.is_null(await t1.wait())

		var t2 := Async.any([1.0, 2.0, 3.0])
		test.is_true(t2.is_completed)
		test.expect(1.0, await t2.wait())

		var t3 := Async.any([
			Async.completed(1.0),
			Async.completed(2.0),
			Async.completed(3.0),
		])
		test.is_true(t3.is_completed)
		test.expect(1.0, await t3.wait())

		var t4 := Async.any([
			Async.delay(1.0),
			Async.completed(2.0),
			3.0,
		])
		test.is_true(t4.is_completed)
		test.expect(2.0, await t4.wait())

		var t5 := Async.any([
			Async.delay(1.0),
			Async.delay(2.0),
			Async.delay(3.0),
		])
		test.is_false(t5.is_completed)
		test.expect(1.0, await t5.wait())

		var t6 := Async.any([
			Async.canceled(),
			Async.delay(2.0),
			Async.delay(3.0),
		])
		test.is_false(t6.is_completed)
		test.expect(2.0, await t6.wait())

		var t7 := Async.any([
			Async.delay(1.0),
			Async.delay(1.0),
			Async.delay(1.0),
		], test.delay_cancel(0.5))
		test.is_false(t7.is_completed)
		test.is_null(await t7.wait())

		var t8 := Async.any([
			Async.delay(1.0),
			2.0,
			Async.completed(3.0),
		])
		test.is_false(t8.is_completed)
		test.is_null(await t8.wait(test.delay_cancel(0.5)))
		test.is_true(t8.is_canceled)
#
#		# ドレインと待機を途中でキャンセル
#		var c9 = test.delay_cancel(0.5)
#		var t9 := Async.all_settled([
#			Async.delay(1.0),
#			2.0,
#			Async.completed(3.0),
#		], c9)
#		# 同一キャンセルを使った場合、ドレイン wait() を優先したいため以下であってる
#		# ドレインキャンセル後 t9.wait() 待機側へシグナルし再開している
#		test.is_false(t9.is_completed)
#		var t9_r = test.is_not_null(await t9.wait())
#		test.is_null(await t9_r[0].wait())
#		test.expect(2.0, await t9_r[1].wait())
#		test.expect(3.0, await t9_r[2].wait())
#		test.is_true(t9.is_completed)
#
#		# キャンセルされた Async を含む
#		var t10 := Async.all_settled([
#			Async.completed(1.0),
#			Async.completed(2.0),
#			Async.canceled(),
#		])
#		test.is_true(t10.is_completed)
#		test.is_false(t10.is_canceled)
#		var t10_r = test.is_not_null(await t10.wait())
#		test.expect(1.0, await t10_r[0].wait())
#		test.expect(2.0, await t10_r[1].wait())
#		test.is_null(await t10_r[2].wait())
#		test.is_true(t9.is_completed)
	)


#class Test:
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
#
#	var _name: String
#	var _pass: int = 0
#	var _next: int = 0
#	var _fail_indices := []
#
#	func _init(name):
#		_name = name
#
#	func _assert(b: bool, k = null):
#		if b:
#			_pass += 1
#		elif k is String:
#			_fail_indices.append(k)
#		else:
#			_fail_indices.append(_next)
#		_next += 1
#


#	Test.new("Async.any()").run(func(t):
#		return
#	)
#
#	Test.new("Async.race()").run(func(t):
#		return
#	)
