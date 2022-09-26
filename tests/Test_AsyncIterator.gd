extends Control

func case(name_: String, test_method: Callable) -> void:
	_test_cases.push_back(TestCase.new(_tree, name_, test_method))

func report() -> void:
	for test_case in _test_cases:
		await test_case.run()
	print("======== END ========")

@onready var _tree := get_tree()
var _test_cases: Array[TestCase] = []

func _ready():

	case("AsyncIterator.from()", func(test):
		var s1 := AsyncIterator.from(func(yield_: Callable) -> void:
			yield_.call(1)
			yield_.call(2)
			yield_.call(3)
		)
		test.is_true(s1.is_completed)
		test.expect(1, await s1.next().wait())
		test.expect(2, await s1.next().wait())
		test.expect(3, await s1.next().wait())

		var s2 := AsyncIterator.from(func(yield_: Callable) -> void:
			await Async.wait_delay(0.15)
			yield_.call(1)
			await Async.wait_delay(0.15)
			yield_.call(2)
			await Async.wait_delay(0.15)
			yield_.call(3)
		)
		test.is_false(s2.is_completed)
		test.expect(1, await s2.next().wait())
		test.expect(2, await s2.next().wait())
		test.expect(3, await s2.next().wait())
		test.is_false(s2.is_completed)
		test.expect(null, await s2.wait())
		test.is_true(s2.is_completed)

		var s3 := AsyncGenerator.from(func(yield_: Callable) -> void:
			await Async.wait_delay(0.15)
			yield_.call(1)
			await Async.wait_delay(0.15)
			yield_.call(2)
			await Async.wait_delay(0.15)
			yield_.call(3)
		)
		var a3_1 := s3.next()
		var a3_2 := s3.next()
		var a3_3 := s3.next()
		var a3_4 := s3.next()
		await s3.wait(Cancel.timeout(0.2)) # *1
		test.expect(1, await a3_1.wait())
		test.expect(2, await a3_2.wait())
		test.expect(3, await a3_3.wait())
		# *1 でキャンセルされているがコルーチンはまだ完走していないため、
		# オーバーラップ分 (a3_4) は待機する必要があります。
		# 出力コールバックのキュー (_set_result_queue) がバランスされるまで待機。
		await a3_4.wait()
		test.is_true(a3_4.is_canceled)

		var s4 := AsyncIterator.from(func(yield_: Callable) -> void:
			await Async.wait_delay(0.15)
			return "abcd"
		)
		test.expect("abcd", await s4.wait())
	)

	await report()
