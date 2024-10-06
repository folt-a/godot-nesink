extends Control

signal _signal0
signal _signal1(arg1: Variant)
signal _signal2(arg1: Variant, arg2: Variant)
signal _signal3(arg1: Variant, arg2: Variant, arg3: Variant)
signal _signal4(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant)
signal _signal5(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant, arg5: Variant)

@onready var _tree := get_tree()

func _emit0() -> void:
	_signal0.emit()

func _emit1(arg1: Variant) -> void:
	_signal1.emit(arg1)

func _emit2(arg1: Variant, arg2: Variant) -> void:
	_signal2.emit(arg1, arg2)

func _emit3(arg1: Variant, arg2: Variant, arg3: Variant) -> void:
	_signal3.emit(arg1, arg2, arg3)

func _emit4(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant) -> void:
	_signal4.emit(arg1, arg2, arg3, arg4)

func _emit5(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant, arg5: Variant) -> void:
	_signal5.emit(arg1, arg2, arg3, arg4, arg5)

func _delay_emit0(timeout: float) -> void:
	_tree.create_timer(timeout).timeout.connect(_emit0)

func _delay_emit1(timeout: float, arg1) -> void:
	_tree.create_timer(timeout).timeout.connect(_emit1.bind(arg1))

func _delay_emit2(timeout: float, arg1, arg2) -> void:
	_tree.create_timer(timeout).timeout.connect(_emit2.bind(arg1, arg2))

func _delay_emit3(timeout: float, arg1, arg2, arg3) -> void:
	_tree.create_timer(timeout).timeout.connect(_emit3.bind(arg1, arg2, arg3))

func _delay_emit4(timeout: float, arg1, arg2, arg3, arg4) -> void:
	_tree.create_timer(timeout).timeout.connect(_emit4.bind(arg1, arg2, arg3, arg4))

func _delay_emit5(timeout: float, arg1, arg2, arg3, arg4, arg5) -> void:
	_tree.create_timer(timeout).timeout.connect(_emit5.bind(arg1, arg2, arg3, arg4, arg5))

func _delay(timeout := 0.2) -> void:
	await _tree.create_timer(timeout).timeout

func _delay_cancel(timeout := 0.1) -> Cancel:
	var cancel := Cancel.new()
	_tree.create_timer(timeout).timeout.connect(cancel.request)
	return cancel

func _equal(array1: Array, array2: Array) -> bool:
	if array1.size() != array2.size():
		return false
	for i in array1.size():
		if array1[i] != array2[i]:
			return false
	return true

func _test_completed() -> void:
	var async := Async.completed()
	assert(async.is_completed)
	assert(not async.is_canceled)
	assert(await async.wait() == null)
	async = Async.completed(123)
	assert(async.is_completed)
	assert(not async.is_canceled)
	assert(await async.wait() == 123)

	%Completed.button_pressed = true

func _test_canceled() -> void:
	var async := Async.canceled()
	assert(not async.is_completed)
	assert(async.is_canceled)
	assert(await async.wait() == null)

	%Canceled.button_pressed = true

func _test_from() -> void:
	var async := Async.from(func (): pass)
	assert(async.is_completed)
	assert(await async.wait() == null)

	async = Async.from(func (): return 123)
	assert(async.is_completed)
	assert(await async.wait() == 123)

	async = Async.from(func(): await _delay())
	assert(not async.is_completed)
	assert(await async.wait() == null)
	assert(async.is_completed)

	async = Async.from(func (): await _delay(); return 123)
	assert(not async.is_completed)
	assert(await async.wait() == 123)
	assert(async.is_completed)

	async = Async.from(func(): await _delay())
	assert(not async.is_completed)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	async = Async.from(func (): await _delay(); return 123)
	assert(not async.is_completed)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	%From.button_pressed = true

func _test_from_signal() -> void:
	var async := Async.from_signal(_signal0)
	assert(not async.is_completed)
	_emit0()
	assert(_equal(await async.wait(), []))
	assert(async.is_completed)

	async = Async.from_signal(_signal1, 1)
	assert(not async.is_completed)
	_emit1(123)
	assert(_equal(await async.wait(), [123]))
	assert(async.is_completed)

	async = Async.from_signal(_signal2, 2)
	assert(not async.is_completed)
	_emit2(123, "abc")
	assert(_equal(await async.wait(), [123, "abc"]))
	assert(async.is_completed)

	async = Async.from_signal(_signal3, 3)
	assert(not async.is_completed)
	_emit3(123, "abc", true)
	assert(_equal(await async.wait(), [123, "abc", true]))
	assert(async.is_completed)

	async = Async.from_signal(_signal4, 4)
	assert(not async.is_completed)
	_emit4(123, "abc", true, null)
	assert(_equal(await async.wait(), [123, "abc", true, null]))
	assert(async.is_completed)

	async = Async.from_signal(_signal5, 5)
	assert(not async.is_completed)
	_emit5(123, "abc", true, null, 0.5)
	assert(_equal(await async.wait(), [123, "abc", true, null, 0.5]))
	assert(async.is_completed)

	async = Async.from_signal(_signal0)
	assert(not async.is_completed)
	_delay_emit0(0.2)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	async = Async.from_signal(_signal1, 1)
	assert(not async.is_completed)
	_delay_emit1(0.2, 123)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	async = Async.from_signal(_signal2, 2)
	assert(not async.is_completed)
	_delay_emit2(0.2, 123, "abc")
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	async = Async.from_signal(_signal3, 3)
	assert(not async.is_completed)
	_delay_emit3(0.2, 123, "abc", true)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	async = Async.from_signal(_signal4, 4)
	assert(not async.is_completed)
	_delay_emit4(0.2, 123, "abc", true, null)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	async = Async.from_signal(_signal5, 5)
	assert(not async.is_completed)
	_delay_emit5(0.2, 123, "abc", true, null, 0.5)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	%FromSignal.button_pressed = true

func _test_from_signal_name() -> void:
	var async := Async.from_signal_name(self, "_signal0")
	assert(not async.is_completed)
	_emit0()
	assert(_equal(await async.wait(), []))
	assert(async.is_completed)

	async = Async.from_signal_name(self, "_signal1", 1)
	assert(not async.is_completed)
	_emit1(123)
	assert(_equal(await async.wait(), [123]))
	assert(async.is_completed)

	async = Async.from_signal_name(self, "_signal2", 2)
	assert(not async.is_completed)
	_emit2(123, "abc")
	assert(_equal(await async.wait(), [123, "abc"]))
	assert(async.is_completed)

	async = Async.from_signal_name(self, "_signal3", 3)
	assert(not async.is_completed)
	_emit3(123, "abc", true)
	assert(_equal(await async.wait(), [123, "abc", true]))
	assert(async.is_completed)

	async = Async.from_signal_name(self, "_signal4", 4)
	assert(not async.is_completed)
	_emit4(123, "abc", true, null)
	assert(_equal(await async.wait(), [123, "abc", true, null]))
	assert(async.is_completed)

	async = Async.from_signal_name(self, "_signal5", 5)
	assert(not async.is_completed)
	_emit5(123, "abc", true, null, 0.5)
	assert(_equal(await async.wait(), [123, "abc", true, null, 0.5]))
	assert(async.is_completed)

	async = Async.from_signal_name(self, "_signal0")
	assert(not async.is_completed)
	_delay_emit0(0.2)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	async = Async.from_signal_name(self, "_signal1", 1)
	assert(not async.is_completed)
	_delay_emit1(0.2, 123)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	async = Async.from_signal_name(self, "_signal2", 2)
	assert(not async.is_completed)
	_delay_emit2(0.2, 123, "abc")
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	async = Async.from_signal_name(self, "_signal3", 3)
	assert(not async.is_completed)
	_delay_emit3(0.2, 123, "abc", true)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	async = Async.from_signal_name(self, "_signal4", 4)
	assert(not async.is_completed)
	_delay_emit4(0.2, 123, "abc", true, null)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	async = Async.from_signal_name(self, "_signal5", 5)
	assert(not async.is_completed)
	_delay_emit5(0.2, 123, "abc", true, null, 0.5)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	%FromSignalName.button_pressed = true

func _test_delay() -> void:
	var async := Async.delay(0.1)
	assert(not async.is_completed)
	assert(await async.wait() == 0.1)

	async = Async.delay(0.2)
	assert(not async.is_completed)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	%Delay.button_pressed = true

func _test_delay_msec() -> void:
	var async := Async.delay_msec(100.0)
	assert(not async.is_completed)
	assert(await async.wait() == 0.1)

	async = Async.delay_msec(200.0)
	assert(not async.is_completed)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	%DelayMsec.button_pressed = true

func _test_delay_usec() -> void:
	var async := Async.delay_usec(100000.0)
	assert(not async.is_completed)
	assert(await async.wait() == 0.1)

	async = Async.delay_usec(200000.0)
	assert(not async.is_completed)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	%DelayUsec.button_pressed = true

func _test_all() -> void:
	var async := Async.all([])
	assert(async.is_completed)
	assert(_equal(await async.wait(), []))

	async = Async.all([123, "abc", true])
	assert(async.is_completed)
	assert(_equal(await async.wait(), [123, "abc", true]))

	async = Async.all([Async.completed(123), Async.completed("abc"), Async.completed(true)])
	assert(async.is_completed)
	assert(_equal(await async.wait(), [123, "abc", true]))

	async = Async.all([Async.completed(123), "abc", Async.completed(true)])
	assert(async.is_completed)
	assert(_equal(await async.wait(), [123, "abc", true]))

	async = Async.all([Async.canceled(), Async.canceled(), Async.canceled()])
	assert(async.is_canceled)
	assert(await async.wait() == null)

	async = Async.all([Async.completed(123), "abc", Async.canceled()])
	assert(async.is_canceled)
	assert(await async.wait() == null)

	async = Async.all([Async.delay(0.2), Async.delay(0.2), Async.delay(0.2)])
	assert(not async.is_completed)
	assert(_equal(await async.wait(), [0.2, 0.2, 0.2]))

	async = Async.all([Async.delay(0.2), Async.delay(0.2), Async.delay(0.2)], Cancel.canceled())
	assert(async.is_canceled)
	assert(await async.wait() == null)

	async = Async.all([Async.delay(0.2), "abc", Async.completed(true)])
	assert(not async.is_completed)
	assert(_equal(await async.wait(), [0.2, "abc", true]))

	async = Async.all([Async.delay(0.2), "abc", Async.completed(true)], _delay_cancel())
	assert(not async.is_completed)
	assert(await async.wait() == null)
	assert(async.is_canceled)

	async = Async.all([Async.delay(0.2), "abc", Async.completed(true)])
	assert(not async.is_completed)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	%All.button_pressed = true

func _test_all_settled() -> void:
	var async := Async.all_settled([])
	assert(async.is_completed)
	var list = await async.wait()
	assert(list.size() == 0)

	async = Async.all_settled([123, "abc", true])
	assert(async.is_completed)
	list = await async.wait()
	assert(list.size() == 3)
	assert(await list[0].wait() == 123)
	assert(await list[1].wait() == "abc")
	assert(await list[2].wait())

	async = Async.all_settled([Async.completed(123), Async.completed("abc"), Async.completed(true)])
	assert(async.is_completed)
	list = await async.wait()
	assert(list.size() == 3)
	assert(await list[0].wait() == 123)
	assert(await list[1].wait() == "abc")
	assert(await list[2].wait())

	async = Async.all_settled([Async.completed(123), "abc", Async.completed(true)])
	assert(async.is_completed)
	list = await async.wait()
	assert(list.size() == 3)
	assert(await list[0].wait() == 123)
	assert(await list[1].wait() == "abc")
	assert(await list[2].wait())

	async = Async.all_settled([Async.canceled(), Async.canceled(), Async.canceled()])
	assert(async.is_completed)
	list = await async.wait()
	assert(list.size() == 3)
	assert(list[0].is_canceled)
	assert(list[1].is_canceled)
	assert(list[2].is_canceled)

	async = Async.all_settled([Async.completed(123), "abc", Async.canceled()])
	assert(async.is_completed)
	list = await async.wait()
	assert(list.size() == 3)
	assert(await list[0].wait() == 123)
	assert(await list[1].wait() == "abc")
	assert(list[2].is_canceled)

	async = Async.all_settled([Async.delay(0.1), Async.delay(0.1), Async.delay(0.1)])
	assert(not async.is_completed)
	list = await async.wait()
	assert(list.size() == 3)
	assert(await list[0].wait() == 0.1)
	assert(await list[1].wait() == 0.1)
	assert(await list[2].wait() == 0.1)

	async = Async.all_settled([Async.delay(0.1), "abc", Async.completed(true)])
	assert(not async.is_completed)
	list = await async.wait()
	assert(list.size() == 3)
	assert(await list[0].wait() == 0.1)
	assert(await list[1].wait() == "abc")
	assert(await list[2].wait())

	async = Async.all_settled([Async.delay(0.2), "abc", Async.completed(true)], _delay_cancel())
	assert(not async.is_completed)
	list = await async.wait()
	assert(list[0].is_canceled)
	assert(await list[1].wait() == "abc")
	assert(await list[2].wait())

	async = Async.all_settled([Async.delay(0.2), "abc", Async.completed(true)])
	assert(not async.is_completed)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	%AllSettled.button_pressed = true

func _test_any() -> void:
	var async := Async.any([])
	assert(async.is_canceled)
	assert(await async.wait() == null)

	async = Async.any([123, "abc", true])
	assert(async.is_completed)
	assert(await async.wait() == 123)

	async = Async.any([Async.completed(123), Async.completed("abc"), Async.completed(true)])
	assert(async.is_completed)
	assert(await async.wait() == 123)

	async = Async.any([Async.completed(123), "abc", Async.completed(true)])
	assert(async.is_completed)
	assert(await async.wait() == 123)

	async = Async.any([Async.canceled(), Async.canceled(), Async.canceled()])
	assert(async.is_canceled)
	assert(await async.wait() == null)

	async = Async.any([Async.completed(123), "abc", Async.canceled()])
	assert(async.is_completed)
	assert(await async.wait() == 123)

	async = Async.any([Async.delay(0.1), Async.delay(0.1), Async.delay(0.1)])
	assert(not async.is_completed)
	assert(await async.wait() == 0.1)
	assert(async.is_completed)

	async = Async.any([Async.delay(0.1), "abc", Async.completed(true)])
	assert(async.is_completed)
	assert(await async.wait() == "abc")

	async = Async.any([Async.delay(0.1), "abc", Async.canceled()], _delay_cancel())
	assert(async.is_completed)
	assert(await async.wait() == "abc")

	async = Async.any([Async.delay(0.2), Async.delay(0.2), Async.delay(0.2)], _delay_cancel())
	assert(not async.is_completed)
	assert(await async.wait() == null)
	assert(async.is_canceled)

	async = Async.any([Async.delay(0.2), Async.delay(0.2), Async.delay(0.2)])
	assert(not async.is_completed)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	async = Async.any([123, "abc", true])
	assert(async.is_completed)
	assert(await async.wait(Cancel.canceled()) == 123)
	assert(async.is_completed)

	%Any.button_pressed = true

func _test_race() -> void:
#	var async := Async.race([])
#	assert(async.is_completed)
#	assert(await async.wait() == null)

	var async := Async.race([123, "abc", true])
	assert(async.is_completed)
	async = await async.wait()
	assert(async is Async)
	assert(await async.wait() == 123)

	async = Async.race([Async.completed(123), Async.completed("abc"), Async.completed(true)])
	assert(async.is_completed)
	async = await async.wait()
	assert(await async.wait() == 123)

	async = Async.race([Async.completed(123), "abc", Async.completed(true)])
	assert(async.is_completed)
	async = await async.wait()
	assert(await async.wait() == 123)

	async = Async.race([Async.canceled(), Async.canceled(), Async.canceled()])
	assert(async.is_completed)
	async = await async.wait()
	assert(async.is_canceled)

	async = Async.race([Async.completed(123), "abc", Async.canceled()])
	assert(async.is_completed)
	async = await async.wait()
	assert(await async.wait() == 123)

	async = Async.race([Async.canceled(), "abc", Async.completed(true)])
	assert(async.is_completed)
	async = await async.wait()
	assert(await async.wait() == "abc")

	async = Async.race([Async.delay(0.1), Async.delay(0.1), Async.delay(0.1)])
	assert(not async.is_completed)
	async = await async.wait()
	assert(await async.wait() == 0.1)

	async = Async.race([Async.delay(0.1), Async.delay(0.1), Async.delay(0.1)], Cancel.canceled())
	assert(async.is_completed)
	async = await async.wait()
	assert(async.is_canceled)

	async = Async.race([Async.delay(0.1), "abc", Async.completed(true)])
	assert(async.is_completed)
	async = await async.wait()
	assert(await async.wait() == "abc")

	async = Async.race([Async.delay(0.2), "abc", Async.completed(true)], _delay_cancel())
	assert(async.is_completed)
	async = await async.wait()
	assert(await async.wait() == "abc")

	async = Async.race([Async.delay(0.2), "abc", Async.completed(true)])
	assert(async.is_completed)
	async = await async.wait(_delay_cancel())
	assert(await async.wait() == "abc")

	async = Async.race([Async.delay(0.2), "abc", Async.completed(true)], _delay_cancel())
	assert(async.is_completed)
	async = await async.wait(_delay_cancel())
	assert(await async.wait() == "abc")

	%Race.button_pressed = true

func _test_then() -> void:
	var async := Async.completed(123).then(func (r): return r * r)
	assert(async.is_completed)
	assert(await async.wait() == 15129)

	async = Async.canceled().then(func (r): return r * r)
	assert(async.is_canceled)
	assert(await async.wait() == null)

	async = Async.delay(0.1).then(func (_r): return 15129)
	assert(not async.is_completed)
	assert(await async.wait() == 15129)

	async = Async.completed(123).then(func (r):
		await Async.wait_delay(0.1)
		return r * r)
	assert(not async.is_completed)
	assert(await async.wait() == 15129)

	async = Async.delay(0.2).then(func (r): return r * r, _delay_cancel())
	assert(not async.is_completed)
	assert(not async.is_canceled)
	assert(await async.wait() == null)
	assert(async.is_canceled)

	async = Async.delay(0.2).then(func (r): return r * r)
	assert(not async.is_completed)
	assert(not async.is_canceled)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	async = Async.delay(0.2).then(func (r): return r * r, _delay_cancel())
	assert(not async.is_completed)
	assert(not async.is_canceled)
	assert(await async.wait(_delay_cancel()) == null)
	assert(async.is_canceled)

	async = Async.delay(0.2).then(func (r): return r * r, Cancel.canceled())
	assert(not async.is_completed)
	assert(async.is_canceled)
	assert(await async.wait(Cancel.canceled()) == null)

	%Then.button_pressed = true

func _test_unwrap() -> void:
	var async := Async.completed(123).unwrap()
	assert(async.is_completed)
	assert(await async.wait() == 123)

	async = Async.completed(Async.completed(123)).unwrap()
	assert(async.is_completed)
	assert(await async.wait() == 123)

	async = Async.completed(Async.completed(Async.completed(123))).unwrap(2)
	assert(async.is_completed)
	assert(await async.wait() == 123)

	async = Async.canceled().unwrap()
	assert(async.is_canceled)
	assert(await async.wait() == null)

	async = Async.completed(Async.delay(0.1)).unwrap()
	assert(not async.is_completed)
	assert(await async.wait() == 0.1)

	async = Async.completed(Async.delay(0.2)).unwrap(1, _delay_cancel(0.1))
	assert(not async.is_completed)
	assert(not async.is_canceled)
	assert(await async.wait() == null)
	assert(async.is_canceled)

	async = Async.completed(Async.completed(Async.delay(0.2))).unwrap(1, _delay_cancel(0.1))
	assert(async.is_completed)
	async = await async.wait()
	assert(not async.is_completed)
	assert(await async.wait() == 0.2)

	%Unwrap.button_pressed = true

func _test_from_conditional_signal() -> void:
	var async := Async.from_conditional_signal(_signal0, [])
	assert(not async.is_completed)
	_emit0()
	assert(_equal(await async.wait(), []))

	async = Async.from_conditional_signal(_signal1, [123])
	assert(not async.is_completed)
	_emit1(456)
	assert(not async.is_completed)
	_emit1(123)
	assert(_equal(await async.wait(), [123]))
	
	async = Async.from_conditional_signal(_signal1, [Async.SKIP])
	assert(not async.is_completed)
	_emit1(123)
	assert(_equal(await async.wait(), [123]))
	
	async = Async.from_conditional_signal(_signal2, [123, "abc"])
	assert(not async.is_completed)
	_emit2(123, "def")
	assert(not async.is_completed)
	_emit2(123, "abc")
	assert(_equal(await async.wait(), [123, "abc"]))
	
	async = Async.from_conditional_signal(_signal2, [123, Async.SKIP])
	assert(not async.is_completed)
	_emit2(123, "abc")
	assert(_equal(await async.wait(), [123, "abc"]))
	
	async = Async.from_conditional_signal(_signal3, [123, "abc", true])
	assert(not async.is_completed)
	_emit3(123, "abc", false)
	assert(not async.is_completed)
	_emit3(123, "abc", true)
	assert(_equal(await async.wait(), [123, "abc", true]))
	
	async = Async.from_conditional_signal(_signal3, [123, "abc", Async.SKIP])
	assert(not async.is_completed)
	_emit3(123, "abc", true)
	assert(_equal(await async.wait(), [123, "abc", true]))
	
	async = Async.from_conditional_signal(_signal4, [123, "abc", true, null])
	assert(not async.is_completed)
	_emit4(123, "abc", true, Object.new())
	assert(not async.is_completed)
	_emit4(123, "abc", true, null)
	assert(_equal(await async.wait(), [123, "abc", true, null]))
	
	async = Async.from_conditional_signal(_signal4, [123, "abc", true, Async.SKIP])
	assert(not async.is_completed)
	_emit4(123, "abc", true, null)
	assert(_equal(await async.wait(), [123, "abc", true, null]))

	async = Async.from_conditional_signal(_signal5, [123, "abc", true, null, 0.5])
	assert(not async.is_completed)
	_emit5(123, "abc", true, null, 1.0)
	assert(not async.is_completed)
	_emit5(123, "abc", true, null, 0.5)
	assert(_equal(await async.wait(), [123, "abc", true, null, 0.5]))
	
	async = Async.from_conditional_signal(_signal5, [123, "abc", true, null, Async.SKIP])
	assert(not async.is_completed)
	_emit5(123, "abc", true, null, 0.5)
	assert(_equal(await async.wait(), [123, "abc", true, null, 0.5]))
	
	%FromConditionalSignal.button_pressed = true

func _test_from_conditional_signal_name() -> void:
	var async := Async.from_conditional_signal_name(self, "_signal0", [])
	assert(not async.is_completed)
	_emit0()
	assert(_equal(await async.wait(), []))

	async = Async.from_conditional_signal_name(self, "_signal1", [123])
	assert(not async.is_completed)
	_emit1(456)
	assert(not async.is_completed)
	_emit1(123)
	assert(_equal(await async.wait(), [123]))
	
	async = Async.from_conditional_signal_name(self, "_signal1", [Async.SKIP])
	assert(not async.is_completed)
	_emit1(123)
	assert(_equal(await async.wait(), [123]))
	
	async = Async.from_conditional_signal_name(self, "_signal2", [123, "abc"])
	assert(not async.is_completed)
	_emit2(123, "def")
	assert(not async.is_completed)
	_emit2(123, "abc")
	assert(_equal(await async.wait(), [123, "abc"]))
	
	async = Async.from_conditional_signal_name(self, "_signal2", [123, Async.SKIP])
	assert(not async.is_completed)
	_emit2(123, "abc")
	assert(_equal(await async.wait(), [123, "abc"]))
	
	async = Async.from_conditional_signal_name(self, "_signal3", [123, "abc", true])
	assert(not async.is_completed)
	_emit3(123, "abc", false)
	assert(not async.is_completed)
	_emit3(123, "abc", true)
	assert(_equal(await async.wait(), [123, "abc", true]))
	
	async = Async.from_conditional_signal_name(self, "_signal3", [123, "abc", Async.SKIP])
	assert(not async.is_completed)
	_emit3(123, "abc", true)
	assert(_equal(await async.wait(), [123, "abc", true]))
	
	async = Async.from_conditional_signal_name(self, "_signal4", [123, "abc", true, null])
	assert(not async.is_completed)
	_emit4(123, "abc", true, Object.new())
	assert(not async.is_completed)
	_emit4(123, "abc", true, null)
	assert(_equal(await async.wait(), [123, "abc", true, null]))
	
	async = Async.from_conditional_signal_name(self, "_signal4", [123, "abc", true, Async.SKIP])
	assert(not async.is_completed)
	_emit4(123, "abc", true, null)
	assert(_equal(await async.wait(), [123, "abc", true, null]))

	async = Async.from_conditional_signal_name(self, "_signal5", [123, "abc", true, null, 0.5])
	assert(not async.is_completed)
	_emit5(123, "abc", true, null, 1.0)
	assert(not async.is_completed)
	_emit5(123, "abc", true, null, 0.5)
	assert(_equal(await async.wait(), [123, "abc", true, null, 0.5]))
	
	async = Async.from_conditional_signal_name(self, "_signal5", [123, "abc", true, null, Async.SKIP])
	assert(not async.is_completed)
	_emit5(123, "abc", true, null, 0.5)
	assert(_equal(await async.wait(), [123, "abc", true, null, 0.5]))
	
	%FromConditionalSignalName.button_pressed = true

func _test_defer() -> void:
	var async := Async.defer(Async.DEFER_IDLE)
	assert(not async.is_completed)
	assert(await async.wait() == null)
	
	async = Async.defer(Async.DEFER_PROCESS_FRAME)
	assert(not async.is_completed)
	assert(await async.wait() == null)

	async = Async.defer(Async.DEFER_PHYSICS_FRAME)
	assert(not async.is_completed)
	assert(await async.wait() == null)
	
	%Defer.button_pressed = true

func _ready() -> void:
	# 1.0.1
	await _test_completed()
	await _test_canceled()
	await _test_from()
	await _test_from_signal()
	await _test_from_signal_name()
	await _test_delay()
	await _test_delay_msec()
	await _test_delay_usec()
	await _test_all()
	await _test_all_settled()
	await _test_any()
	await _test_race()
	await _test_then()
	await _test_unwrap()

	# 1.0.2
	await _test_defer()
	await _test_from_conditional_signal()
	await _test_from_conditional_signal_name()
