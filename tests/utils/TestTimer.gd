class_name TestTimer

func stop(epsilon := 0.05, marker = null) -> void:
	var delta: float = (Time.get_ticks_msec() - _start_ticks) / 1000.0 - _expect_delta
	if marker is String:
		_test_case.is_true(abs(delta) <= epsilon, marker)
	else:
		_test_case.is_true(abs(delta) <= epsilon, "誤差 |%.3f|s が許容範囲 %.3fs を上回った" % [delta - _expect_delta, epsilon])

var _test_case
var _expect_delta: float
var _start_ticks

func _init(test_case: TestCase, expect_delta: float) -> void:
	_test_case = test_case
	_expect_delta = expect_delta
	_start_ticks = Time.get_ticks_msec()
