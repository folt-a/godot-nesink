extends Control

func _on_async_all_pressed():
	$AsyncAll.disabled = true
	$AsyncAllStatus/_1.button_pressed = false
	$AsyncAllStatus/_2.button_pressed = false
	$AsyncAllStatus/_3.button_pressed = false
	$AsyncAllStatus/_4.button_pressed = false
	$AsyncAllStatus/Label.text = "Pending."

	var cancel := Cancel.new()
	$AsyncAllCancel.pressed.connect(cancel.request)
	$AsyncAllCancel.disabled = false

	var async := Async.all([
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncAllStatus/_1.button_pressed = true),
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncAllStatus/_2.button_pressed = true),
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncAllStatus/_3.button_pressed = true),
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncAllStatus/_4.button_pressed = true),
	], cancel)
	await async.wait()
	$AsyncAllStatus/Label.text = "Completed." if async.is_completed else "Canceled."

	#
	# 恐らくバグ (20d667284)
	# このように書くとエラーが出る
	#
	#await Async.wait_all([
	#	Async.from(func(): await Async.wait_delay(randf() + 0.5); if not cancel.is_requested: $AsyncAllStatus/_1.button_pressed = true),
	#	Async.from(func(): await Async.wait_delay(randf() + 0.5); if not cancel.is_requested: $AsyncAllStatus/_2.button_pressed = true),
	#	Async.from(func(): await Async.wait_delay(randf() + 0.5); if not cancel.is_requested: $AsyncAllStatus/_3.button_pressed = true),
	#	Async.from(func(): await Async.wait_delay(randf() + 0.5); if not cancel.is_requested: $AsyncAllStatus/_4.button_pressed = true),
	#], cancel)

	$AsyncAllCancel.disabled = true
	$AsyncAll.disabled = false

func _on_async_all_settled_pressed():
	$AsyncAllSettled.disabled = true
	$AsyncAllSettledStatus/_1.button_pressed = false
	$AsyncAllSettledStatus/_2.button_pressed = false
	$AsyncAllSettledStatus/_3.button_pressed = false
	$AsyncAllSettledStatus/_4.button_pressed = false
	$AsyncAllSettledStatus/Label.text = "Pending."

	var cancel := Cancel.new()
	$AsyncAllSettledCancel.pressed.connect(cancel.request)
	$AsyncAllSettledCancel.disabled = false

	var async := Async.all_settled([
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncAllSettledStatus/_1.button_pressed = true),
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncAllSettledStatus/_2.button_pressed = true),
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncAllSettledStatus/_3.button_pressed = true),
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncAllSettledStatus/_4.button_pressed = true),
	], cancel).then(func(results):
		$AsyncAllSettledCancel.disabled = true
		$AsyncAllSettled.disabled = false)
	await async.wait()
	$AsyncAllSettledStatus/Label.text = "Completed." if async.is_completed else "Canceled."

func _on_async_any_pressed():
	$AsyncAny.disabled = true
	$AsyncAnyStatus/_1.button_pressed = false
	$AsyncAnyStatus/_2.button_pressed = false
	$AsyncAnyStatus/_3.button_pressed = false
	$AsyncAnyStatus/_4.button_pressed = false
	$AsyncAnyStatus/Label.text = "Pending."

	var cancel := Cancel.new()
	$AsyncAnyCancel.pressed.connect(cancel.request)
	$AsyncAnyCancel.disabled = false

	var async := Async.any([
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncAnyStatus/_1.button_pressed = true),
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncAnyStatus/_2.button_pressed = true),
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncAnyStatus/_3.button_pressed = true),
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncAnyStatus/_4.button_pressed = true),
	], cancel)
	await async.wait()
	$AsyncAnyStatus/Label.text = "Completed." if async.is_completed else "Canceled."

	$AsyncAnyCancel.disabled = true
	$AsyncAny.disabled = false

func _on_async_race_pressed():
	$AsyncRace.disabled = true
	$AsyncRaceStatus/_1.button_pressed = false
	$AsyncRaceStatus/_2.button_pressed = false
	$AsyncRaceStatus/_3.button_pressed = false
	$AsyncRaceStatus/_4.button_pressed = false
	$AsyncRaceStatus/Label.text = "Pending."

	var cancel := Cancel.new()
	$AsyncRaceCancel.pressed.connect(cancel.request)
	$AsyncRaceCancel.disabled = false

	var async := Async.race([
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncRaceStatus/_1.button_pressed = true),
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncRaceStatus/_2.button_pressed = true),
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncRaceStatus/_3.button_pressed = true),
		Async.from(func(): await Async.wait_delay(randf() + 1.0); if not cancel.is_requested: $AsyncRaceStatus/_4.button_pressed = true),
	], cancel).then(func(result):
		$AsyncRaceCancel.disabled = true
		$AsyncRace.disabled = false)
	await async.wait()
	$AsyncRaceStatus/Label.text = "Completed." if async.is_completed else "Canceled."

func _on_async_then_pressed():
	$AsyncThen.disabled = true
	$AsyncThenStatus/_1.button_pressed = false
	$AsyncThenStatus/_2.button_pressed = false
	$AsyncThenStatus/_3.button_pressed = false
	$AsyncThenStatus/_4.button_pressed = false
	$AsyncThenStatus/Label.text = "Pending."

	var cancel := Cancel.new()
	$AsyncThenCancel.pressed.connect(cancel.request)
	$AsyncThenCancel.disabled = false

	var async := Async\
		.from(func(): await Async.wait_delay(0.5); if not cancel.is_requested: $AsyncThenStatus/_1.button_pressed = true) \
		.then(func(): await Async.wait_delay(0.5); if not cancel.is_requested: $AsyncThenStatus/_2.button_pressed = true, cancel) \
		.then(func(): await Async.wait_delay(0.5); if not cancel.is_requested: $AsyncThenStatus/_3.button_pressed = true, cancel) \
		.then(func(): await Async.wait_delay(0.5); if not cancel.is_requested: $AsyncThenStatus/_4.button_pressed = true, cancel)
	await async.wait()
	$AsyncThenStatus/Label.text = "Completed." if async.is_completed else "Canceled."
	$AsyncThenCancel.disabled = true
	$AsyncThen.disabled = false
