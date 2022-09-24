extends Node

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

func create_timer(timeout: float) -> SceneTreeTimer:
	return _tree.create_timer(timeout)

func create_completed_async(result = null) -> Async:
	return \
		_completed_async if result == null else \
		NesinkronaCompletedAsync.new(result)

func create_canceled_async() -> Async:
	return _canceled_async

func create_canceled_cancel() -> Cancel:
	return _canceled_cancel

#-------------------------------------------------------------------------------

@onready
var _tree := get_tree()
var _completed_async := NesinkronaCompletedAsync.new(null)
var _canceled_async := NesinkronaCanceledAsync.new()
var _canceled_cancel := Cancel.new()

func _init() -> void:
	_canceled_cancel.request()
