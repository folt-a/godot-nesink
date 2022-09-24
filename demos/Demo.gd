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

	$Background/Line1.set("theme_override_constants/outline_size", 2.0)
	$Background/Line2.set("theme_override_constants/outline_size", 2.0)
	$Background/Line3.set("theme_override_constants/outline_size", 2.0)
	$Background/Line4.set("theme_override_constants/outline_size", 2.0)

	$Background/Line1.visible_ratio = 0.0
	$Background/Line2.visible_ratio = 0.0
	$Background/Line3.visible_ratio = 0.0
	$Background/Line4.visible_ratio = 0.0

	var async := Async.all([
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line1, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncAllStatus/_1.button_pressed = true),
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line2, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncAllStatus/_2.button_pressed = true),
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line3, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncAllStatus/_3.button_pressed = true),
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line4, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncAllStatus/_4.button_pressed = true),
	], cancel)

	await async.wait()

	if async.is_completed:
		$Background/Line1.set("theme_override_constants/outline_size", 0.0)
		$Background/Line2.set("theme_override_constants/outline_size", 0.0)
		$Background/Line3.set("theme_override_constants/outline_size", 0.0)
		$Background/Line4.set("theme_override_constants/outline_size", 0.0)

		$AsyncAllStatus/Label.text = "Completed."

	else:
		$AsyncAllStatus/Label.text = "Canceled."

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

	$Background/Line1.set("theme_override_constants/outline_size", 2.0)
	$Background/Line2.set("theme_override_constants/outline_size", 2.0)
	$Background/Line3.set("theme_override_constants/outline_size", 2.0)
	$Background/Line4.set("theme_override_constants/outline_size", 2.0)

	$Background/Line1.visible_ratio = 0.0
	$Background/Line2.visible_ratio = 0.0
	$Background/Line3.visible_ratio = 0.0
	$Background/Line4.visible_ratio = 0.0

	var async := Async.all_settled([
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line1, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncAllSettledStatus/_1.button_pressed = true),
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line2, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncAllSettledStatus/_2.button_pressed = true),
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line3, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncAllSettledStatus/_3.button_pressed = true),
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line4, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncAllSettledStatus/_4.button_pressed = true),
	], cancel)
	await async.wait()

	$Background/Line1.set("theme_override_constants/outline_size", 0.0)
	$Background/Line2.set("theme_override_constants/outline_size", 0.0)
	$Background/Line3.set("theme_override_constants/outline_size", 0.0)
	$Background/Line4.set("theme_override_constants/outline_size", 0.0)

	$AsyncAllSettledStatus/Label.text = "Completed."

	$AsyncAllSettledCancel.disabled = true
	$AsyncAllSettled.disabled = false

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

	$Background/Line1.set("theme_override_constants/outline_size", 2.0)
	$Background/Line2.set("theme_override_constants/outline_size", 2.0)
	$Background/Line3.set("theme_override_constants/outline_size", 2.0)
	$Background/Line4.set("theme_override_constants/outline_size", 2.0)

	$Background/Line1.visible_ratio = 0.0
	$Background/Line2.visible_ratio = 0.0
	$Background/Line3.visible_ratio = 0.0
	$Background/Line4.visible_ratio = 0.0

	var async := Async.any([
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line1, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncAnyStatus/_1.button_pressed = true),
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line2, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncAnyStatus/_2.button_pressed = true),
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line3, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncAnyStatus/_3.button_pressed = true),
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line4, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncAnyStatus/_4.button_pressed = true),
	], cancel)
	await async.wait()

	if async.is_completed:
		$Background/Line1.set("theme_override_constants/outline_size", 0.0)
		$Background/Line2.set("theme_override_constants/outline_size", 0.0)
		$Background/Line3.set("theme_override_constants/outline_size", 0.0)
		$Background/Line4.set("theme_override_constants/outline_size", 0.0)

		$AsyncAnyStatus/Label.text = "Completed."

	else:
		$AsyncAnyStatus/Label.text = "Canceled."

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

	$Background/Line1.set("theme_override_constants/outline_size", 2.0)
	$Background/Line2.set("theme_override_constants/outline_size", 2.0)
	$Background/Line3.set("theme_override_constants/outline_size", 2.0)
	$Background/Line4.set("theme_override_constants/outline_size", 2.0)

	$Background/Line1.visible_ratio = 0.0
	$Background/Line2.visible_ratio = 0.0
	$Background/Line3.visible_ratio = 0.0
	$Background/Line4.visible_ratio = 0.0

	var async := Async.race([
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line1, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncRaceStatus/_1.button_pressed = true),
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line2, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncRaceStatus/_2.button_pressed = true),
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line3, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncRaceStatus/_3.button_pressed = true),
		Async.from(func():
			await Async.wait_delay(randf() * 2.0, cancel)
			var tween := create_tween()
			tween.tween_property($Background/Line4, "visible_ratio", 1.0, 2.0)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncRaceStatus/_4.button_pressed = true),
	], cancel)
	await async.wait()
	#cancel.request()

	$Background/Line1.set("theme_override_constants/outline_size", 0.0)
	$Background/Line2.set("theme_override_constants/outline_size", 0.0)
	$Background/Line3.set("theme_override_constants/outline_size", 0.0)
	$Background/Line4.set("theme_override_constants/outline_size", 0.0)

	$AsyncRaceStatus/Label.text = "Completed."

	$AsyncRaceCancel.disabled = true
	$AsyncRace.disabled = false

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

	$Background/Line1.set("theme_override_constants/outline_size", 2.0)
	$Background/Line2.set("theme_override_constants/outline_size", 2.0)
	$Background/Line3.set("theme_override_constants/outline_size", 2.0)
	$Background/Line4.set("theme_override_constants/outline_size", 2.0)

	$Background/Line1.visible_ratio = 0.0
	$Background/Line2.visible_ratio = 0.0
	$Background/Line3.visible_ratio = 0.0
	$Background/Line4.visible_ratio = 0.0

	var async := Async\
		.from(func(  ):
			var tween := create_tween()
			tween.tween_property($Background/Line1, "visible_ratio", 1.0, 0.5)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncThenStatus/_1.button_pressed = true) \
		.then(func(__):
			var tween := create_tween()
			tween.tween_property($Background/Line2, "visible_ratio", 1.0, 0.5)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncThenStatus/_2.button_pressed = true, cancel) \
		.then(func(__):
			var tween := create_tween()
			tween.tween_property($Background/Line3, "visible_ratio", 1.0, 0.5)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncThenStatus/_3.button_pressed = true, cancel) \
		.then(func(__):
			var tween := create_tween()
			tween.tween_property($Background/Line4, "visible_ratio", 1.0, 0.5)
			tween.play()
			await Async.from_signal(tween.finished).wait(cancel)
			tween.stop()
			if not cancel.is_requested:
				$AsyncThenStatus/_4.button_pressed = true, cancel)
	await async.wait()
	#cancel.request()

	if async.is_completed:
		$Background/Line1.set("theme_override_constants/outline_size", 0.0)
		$Background/Line2.set("theme_override_constants/outline_size", 0.0)
		$Background/Line3.set("theme_override_constants/outline_size", 0.0)
		$Background/Line4.set("theme_override_constants/outline_size", 0.0)

		$AsyncThenStatus/Label.text = "Completed."
	else:
		$AsyncThenStatus/Label.text = "Canceled."

	$AsyncThenCancel.disabled = true
	$AsyncThen.disabled = false

func _on_async_iterator_pressed():
	$AsyncIterator.disabled = true
	$AsyncIteratorNextStatus/_1.button_pressed = false
	$AsyncIteratorNextStatus/_2.button_pressed = false
	$AsyncIteratorNextStatus/_3.button_pressed = false
	$AsyncIteratorNextStatus/_4.button_pressed = false
	$AsyncIteratorNextStatus/Label.text = "Pending."

	$Background/Line1.set("theme_override_constants/outline_size", 2.0)
	$Background/Line2.set("theme_override_constants/outline_size", 2.0)
	$Background/Line3.set("theme_override_constants/outline_size", 2.0)
	$Background/Line4.set("theme_override_constants/outline_size", 2.0)

	$Background/Line1.visible_ratio = 0.0
	$Background/Line2.visible_ratio = 0.0
	$Background/Line3.visible_ratio = 0.0
	$Background/Line4.visible_ratio = 0.0

	var seq := AsyncIterator.from(func(yield_):
		await Async.delay(2.0).wait()
		yield_.call(1)
		await Async.delay(2.0).wait()
		yield_.call(2)
		await Async.delay(2.0).wait()
		yield_.call(3)
		await Async.delay(2.0).wait()
		yield_.call(4))

	var handle_pressed := func():
		$AsyncIteratorNext.disabled = true
		var next_async = seq.next()
		var line = await next_async.wait()
		get_node("Background/Line%d" % line).visible_ratio = 1.0
		get_node("AsyncIteratorNextStatus/_%d" % line).button_pressed = true
		$AsyncIteratorNext.disabled = false

	$AsyncIteratorNext.disabled = false
	$AsyncIteratorNext.pressed.connect(handle_pressed)

	await seq.wait()

	$AsyncIteratorNext.pressed.disconnect(handle_pressed)
	$AsyncIteratorNext.disabled = true
	$AsyncIterator.disabled = false

	$AsyncIteratorNextStatus/Label.text = "Completed."
	$Background/Line1.set("theme_override_constants/outline_size", 0.0)
	$Background/Line2.set("theme_override_constants/outline_size", 0.0)
	$Background/Line3.set("theme_override_constants/outline_size", 0.0)
	$Background/Line4.set("theme_override_constants/outline_size", 0.0)
