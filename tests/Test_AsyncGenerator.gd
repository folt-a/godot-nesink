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

	case("AsyncGenerator.from()", func(test):

		var s1 := AsyncGenerator.from(func(yield_: Callable) -> void:
			test.expect("a", await yield_.call(1).wait())
			test.expect("b", await yield_.call(2).wait())
			test.expect("c", await yield_.call(3).wait())
		)
		test.is_false(s1.is_completed)
		test.expect(1, await s1.next("a").wait())
		test.expect(2, await s1.next("b").wait())
		test.expect(3, await s1.next("c").wait())
		test.is_true(s1.is_completed)
		test.is_null(await s1.wait())
		test.is_true(s1.is_completed)

		var s3 := AsyncGenerator.from(func(yield_: Callable) -> void:
			await Async.wait_delay(0.15)
			test.expect("a", await yield_.call(1).wait())
			await Async.wait_delay(0.15)
			test.expect("b", await yield_.call(2).wait())
			await Async.wait_delay(0.15)
			test.expect("c", await yield_.call(3).wait())
			return 1234
		)
		var a3_1 := s3.next("a")
		var a3_2 := s3.next("b")
		var a3_3 := s3.next("c")
		var a3_4 := s3.next("d")
		await s3.wait(Cancel.timeout(0.2)) # *1
		test.expect(1, await a3_1.wait())
		test.expect(2, await a3_2.wait())
		test.expect(3, await a3_3.wait())
		# *1 でキャンセルされているがコルーチンはまだ完走していないため、
		# オーバーラップ分 (a3_4) は待機する必要があります。
		# 入出力コールバックのキュー (_set_result_queue, _set_value_queue) がバランスされるまで待機。
		await a3_4.wait()
		test.is_true(a3_4.is_canceled)
	)

	await report()
